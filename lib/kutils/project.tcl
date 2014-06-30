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
    #   version        - The version number, x.y.z-suffix
    #   pkgversion     - The version number, less suffix
    #   description    - The project title
    #   appkit         - Name of project appkit, or "" if none.
    #   shell          - Shell initialization script for "kite shell -plain"
    #
    #   libs           - List of library package names
    #   lib-$name      - Info dict for the lib (not yet needed)
    #
    #   includes       - List of include names
    #   include-$name  - inclusion dictionary for the $name
    #
    #       vcs - git|svn
    #       url - The repository URL
    #       tag - The version/branch tag
    #
    #   requires       - Names of required teapot packages
    #   require-$name  - Version of required package $name
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name           ""
        version        ""
        pkgversion     ""
        description    ""
        appkit         ""
        libs           {}
        includes       {}
        requires       {}
        shell          {}
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
        $safe alias lib     [myproc LibCmd]
        $safe alias include [myproc IncludeCmd]
        $safe alias require [myproc RequireCmd]
        $safe alias shell   [myproc ShellCmd]


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
            # This will result in a stack trace; add cases above
            # for things we find that aren't really project.kite errors.
            error $result
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
        prepare name        -required -tolower
        prepare version     -required
        prepare description -required

        if {![BaseName? $name]} {
            throw SYNTAX "Invalid project name: \"$name\""
        }

        if {![Version? $version]} {
            throw SYNTAX "Invalid version number: \"$version\""
        }

        set info(name)        $name
        set info(version)     $version
        set info(pkgversion)  [lindex [split $version -] 0]
        set info(description) $description
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

    # LibCmd name
    #
    # Implementation of the "lib" kite file command.

    proc LibCmd {name} {
        set name [string trim [string tolower $name]]

        if {![regexp {^[a-z]\w*$} $name]} {
            throw SYNTAX "Invalid lib name \"$name\""
        }

        if {$name in $info(libs)} {
            throw SYNTAX "Duplicate lib name \"$name\""
        }
        ladd info(libs) $name
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

        if {$name in [concat $info(includes) $info(requires)]} {
            throw SYNTAX "Duplicate include/require name: \"$name\""
        }

        ladd info(includes) $name
        set info(include-$name) \
            [dict create vcs $vcs url $url tag $tag]
    }

    # RequireCmd name version
    #
    # name      - The name of the teapot package
    # version   - The version number of the teapot package
    #
    # States that the project depends on the given package from 
    # a teapot repository.

    proc RequireCmd {name version} {
        if {$name in [concat $info(includes) $info(requires)]} {
            throw SYNTAX "Duplicate include/require name: \"$name\""
        }

        ladd info(requires) $name
        set info(require-$name) $version
    }

    # ShellCmd script
    #
    # Implementation of the "shell" kite file command.

    proc ShellCmd {script} {
        set info(shell) $script
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
    # Validates the version, which must be a valid Tcl package 
    # version number with an optional "-suffix".

    proc Version? {ver} {
        return [regexp {^(\d[.])*\d[.ab]\d(-\w+)?$} $ver]
    }

    #-------------------------------------------------------------------
    # Saving project metadata for use by the project's own code.



    # metadata save
    #
    # Saves the project metadata to disk as appropriate.

    typemethod {metadata save} {} {
        # FIRST, if there's an appkit save the kiteinfo package for
        # its use.
        if {$info(appkit) ne ""} {
            SaveKiteInfo
        }

        # NEXT, for each declared library, update its version number
        # in the pkgIndex and pkgModules files.
        foreach lib $info(libs) {
            UpdateLibVersion $lib
        }
    }


    # SaveKiteInfo
    #
    # Saves the kiteinfo package to lib/kiteinfo/*.
    #
    # TODO: We probably don't want to include everything in info().

    proc SaveKiteInfo {} {
        gentree [project root lib kiteinfo] {
            pkgIndex   pkgIndex.tcl
            pkgModules pkgModules.tcl
            kiteinfo   kiteinfo.tcl
        } %project  $info(name) \
          %package  kiteinfo    \
          %module   kiteinfo    \
          %kiteinfo [list [array get info]]
    }

    # UpdateLibVersion lib
    #
    # lib   - Name of a library package
    #
    # Updates the version number in the pkgIndex.tcl and pkgModules.tcl
    # files for the given library.

    proc UpdateLibVersion {lib} {
        try {
            # FIRST, pkgIndex.tcl
            set fname [project root lib $lib pkgIndex.tcl]

            if {[file exists $fname]} {
                set oldText [readfile $fname]
                set content "package ifneeded $lib $info(pkgversion) "
                append content \
                    {[list source [file join $dir pkgModules.tcl]]}

                set newText [ReplaceBlock $oldText ifneeded $content]

                writefile $fname $newText -ifchanged
            }

            # NEXT, pkgModules.tcl
            set fname [project root lib $lib pkgModules.tcl]

            if {[file exists $fname]} {
                set oldText [readfile $fname]
                set content "package provide $lib $info(pkgversion)"
                set newText [ReplaceBlock $oldText provide $content]

                writefile $fname $newText -ifchanged
            }
        } trap POSIX {result} {
            throw FATAL "Error updating \"$lib\" version: $result"
        }
    }

    # ReplaceBlock text tag content
    #
    # text    - The contents of a text file
    # tag     - A replacement tag, e.g., "ifneeded"
    # content - A text string
    #
    # Looks for the 'kite-start' and 'kite-end' lines for the given
    # tag, and replaces the text between them with the given content.

    proc ReplaceBlock {text tag content} {
        # FIRST, prepare
        set inlines [split $text "\n"]
        set outlines [list]
        set inBlock 0

        # NEXT, find and replace the block
        foreach line $inlines {
            if {!$inBlock} {
                if {[string match "# -kite-start-$tag *" $line]} {
                    lappend outlines $line $content
                    set inBlock 1
                } else {
                    lappend outlines $line
                }
            } else {
                # In Block.  Skip everything but end.
                if {[string match "# -kite-end-*" $line]} {
                    lappend outlines $line
                    set inBlock 0
                }
            }
        }

        # NEXT, return the new text.
        return [join $outlines "\n"]

    }
    

    #-------------------------------------------------------------------
    # Other Queries

    # version
    #
    # Returns the full version string.

    typemethod version {} {
        return $info(version)
    }

    # pkgversion
    #
    # Returns the [package require] form of the version string.

    typemethod pkgversion {} {
        return $info(pkgversion)
    }

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

    # apploader
    #
    # Returns the project's application loader script.
    #
    # TODO: Support apps as well as appkits

    typemethod apploader {} {
        if {$info(appkit) eq ""} {
            return ""
        }

        return [project root bin $info(appkit).tcl]
    }

    # lib names
    #
    # Returns the list of lib names.

    typemethod {lib names} {} {
        return $info(libs)
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

    # require names
    #
    # Returns the list of required package names.

    typemethod {require names} {} {
        return $info(requires)
    }

    # require version name
    #
    # name  - the require name
    #
    # Returns the required package's version.

    typemethod {require version} {name} {
        return $info(require-$name)
    }

    # shell
    #
    # Returns the shell initialization script.

    typemethod shell {} {
        return $info(shell)
    }

    # libpath
    #
    # Returns a Tcl list of library directories associated with this 
    # project.

    typemethod libpath {} {
        set path [list]

        foreach iname $info(includes) {
            lappend path [project root includes $iname lib]
        }

        lappend path [project root lib]

        return $path
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

        foreach name $info(libs) {
            DumpValue "Lib:" "$name"
        }

        puts ""

        if {[llength $info(includes)] > 0} {
            foreach name $info(includes) {
                array set d $info(include-$name)
                DumpValue "Include:"  "$name as $d(vcs) $d(url) $d(tag)"
            }

            puts ""
        }

        if {[llength $info(requires)] > 0} {
            foreach name $info(requires) {
                DumpValue "Require:"  "$name $info(require-$name)"
            }

            puts ""
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



