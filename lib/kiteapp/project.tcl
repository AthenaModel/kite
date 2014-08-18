#-----------------------------------------------------------------------
# TITLE:
#   project.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) project file reader/writing
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# project ensemble

snit::type project {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Constants
    
    # The project file name.
    typevariable projfile "project.kite"

    #-------------------------------------------------------------------
    # Constants

    # Default src -build and -clean scripts

    typevariable defaultBuild "make clean all"
    typevariable defaultClean "make clean"
    

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
    #   poc            - Point-of-contact e-mail address
    #   shell          - Shell initialization script for "kite shell -plain"
    #
    #   apps           - List of project app names, or "" if none.
    #   apptype-$app   - kit or exe
    #   gui-$app       - 1 or 0
    #
    #   provides       - List of provided library package names
    #   binary-$name   - 1 if package is binary, and 0 otherwise.
    #
    #   includes       - List of include names
    #   include-$name  - inclusion dictionary for the $name
    #
    #       vcs - git|svn
    #       url - The repository URL
    #       tag - The version/branch tag
    #
    #   requires       - Names of required teapot packages
    #   require-$name  - Info dictionary for the required package
    #
    #       version    - Version of required package $name
    #       local      - 1 if this is a local package, and 0 otherwise.
    #
    #   srcs           - Names of "src" targets
    #   build-$src     - Script to build contents of $src
    #   clean-$src     - Script to clean contents of $src
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name           ""
        version        ""
        pkgversion     ""
        description    ""
        poc            ""
        apps           ""
        provides       {}
        includes       {}
        requires       {}
        srcs           {}
        shell          {}
    }

    #-------------------------------------------------------------------
    # File and Directory Queries

    # newroot name
    #
    # name   - A project name
    #
    # Creates a new project root directory with the given name, and 
    # CD's into it.  Does not load or simulate any project metadata.

    typemethod newroot {name} {
        set rootdir [file join [pwd] $name]
        file mkdir $rootdir
    }

    # root ?names...?
    #
    # Find and return the directory containing the project.kite file, which
    # by definition is the top directory for the project.  Cache the
    # name for later.  If "names..." are given, join them to the 
    # dir name and return that.
    #
    # If we cannot find the project directory, throw an error with
    # code FATAL.
    #
    # TODO: Split path components on "/" before rejoining?

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

    # globroot ?patterns...?
    #
    # patterns - A list of path components, possibly containing wildcards.
    #
    # Joins the patterns to the project root directory, and does a 
    # glob -nocomplain, returning the resulting list.

    typemethod globroot {args} {
        glob -nocomplain [$type root {*}$args]
    }

    # globdirs ?patterns...?
    #
    # patterns - A list of path components, possibly containing wildcards.
    #
    # Joins the patterns to the project root directory, and does a 
    # glob -nocomplain, returning the directory names in the resulting
    # list.

    typemethod globdirs {args} {
        set result [list]
        foreach name [$type globroot {*}$args] {
            if {[file isdirectory $name]} {
                lappend result $name
            }
        }

        return $result
    }

    # globfiles ?patterns...?
    #
    # patterns - A list of path components, possibly containing wildcards.
    #
    # Joins the patterns to the project root directory, and does a 
    # glob -nocomplain, returning the names of the normal files 
    # from the resulting list.

    typemethod globfiles {args} {
        set result [list]
        foreach name [$type globroot {*}$args] {
            if {[file isfile $name]} {
                lappend result $name
            }
        }

        return $result
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
    # Metadata Queries

    # tclsh
    #
    # Returns the name of the development Tclsh (i.e., the one being
    # used to run Kite).
    #
    # TODO: Move all helper paths to a platform module.

    typemethod tclsh {} {
        # Normalizing ensures that the case of the path components
        # is what it should be on Windows.  (I.e., "C:" rather than
        # "c:".)
        return [file normalize [info nameofexecutable]]
    }

    # teapot
    #
    # Returns the path to Kite's local teapot repository

    typemethod teapot {} {
        return [file normalize [file join ~ .kite teapot]]
    }

    # name
    #
    # Returns the project name.

    typemethod name {} {
        return $info(name)
    }

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

    # description
    #
    # Returns the project description.

    typemethod description {} {
        return $info(description)
    }

    # poc
    #
    # Returns the project POC.

    typemethod poc {} {
        return $info(poc)
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

    # hasapp
    #
    # Returns 1 if the project defines an application.

    typemethod hasapp {} {
        return [expr {[llength $info(apps)] > 0}]
    }

    # app names
    #
    # Returns the list of project app names, if any.

    typemethod {app names} {} {
        return $info(apps)
    }

    # app primary
    #
    # Returns the primary application name, or ""

    typemethod {app primary} {} {
        return [lindex $info(apps) 0]
    }

    # app apptype app
    #
    # app - The application name
    #
    # Returns the apptype, kit|exe

    typemethod {app apptype} {app} {
        return $info(apptype-$app)
    }

    # app gui app
    #
    # app - The application name
    #
    # Returns the app's GUI flag, 1 or 0.

    typemethod {app gui} {app} {
        return $info(gui-$app)
    }


    # app loader app
    #
    # app - The application name
    #
    # Returns the project's application loader script.

    typemethod {app loader} {app} {
        return [project root bin $app.tcl]
    }

    # app exefile app
    #
    # app - The application name
    #
    # Returns the app's executable file, given its app type and
    # the platform.

    typemethod {app exefile} {app} {
        if {[project app apptype $app] eq "kit"} {
            return $app.kit
        } elseif {[project app apptype $app] eq "exe"} {
            if {$::tcl_platform(platform) eq "windows"} {
                return exefile "$app.exe"
            } else {
                return exefile $app
            }
        } else {
            error "Unknown application type"
        }
    }

    # provide names
    #
    # Returns the list of provide names.

    typemethod {provide names} {} {
        return $info(provides)
    }

    # provide binary name
    #
    # name - Name of the provided library
    #
    # Returns 1 if the library has a binary component, and 0 otherwise.

    typemethod {provide binary} {name} {
        return $info(binary-$name)
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
        return [dict get $info(require-$name) version]
    }

    # require islocal name
    #
    # name  - the require name
    #
    # Returns 1 if the required package is internally built.

    typemethod {require islocal} {name} {
        return [dict get $info(require-$name) local]
    }

    # src names
    #
    # Returns the list of "src" directory names.

    typemethod {src names} {} {
        return $info(srcs)
    }

    # src build src
    #
    # src  - A src directory name, as returned by [project src names]
    # 
    # Returns the "build" script.

    typemethod {src build} {src} {
        return $info(build-$src)
    }

    # src clean src
    #
    # src  - A src directory name, as returned by [project src names]
    # 
    # Returns the "clean" script.

    typemethod {src clean} {src} {
        return $info(clean-$src)
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

    # zippath
    #
    # Returns the path where "kite build" puts teapot .zip packages,
    # creating the directory if needed.

    typemethod zippath {} {
        set path [project root .kite libzips]
        file mkdir $path
        return $path
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
        $safe alias poc     [myproc PocCmd]
        $safe alias app     [myproc AppCmd]
        $safe alias provide [myproc ProvideCmd]
        $safe alias include [myproc IncludeCmd]
        $safe alias require [myproc RequireCmd]
        $safe alias src     [myproc SrcCmd]
        $safe alias shell   [myproc ShellCmd]


        # NEXT, try to load the file
        try {
            $safe eval [readfile [$type root $projfile]]
        } trap INVALID {result} {
            throw FATAL "Error in project.kite: $result"
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
            return {*}$eopts $result
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
    
    # PocCmd poc
    #
    # Implementation of the "poc" kite file command.

    proc PocCmd {poc} {
        prepare poc -required

        set info(poc)  $poc
    }

    # AppCmd name ?options...?
    #
    # Implementation of the "app" kite file command.

    proc AppCmd {name args} {
        # FIRST, validate the name.
        set name [string trim [string tolower $name]]

        if {![regexp {^[a-z]\w*$} $name]} {
            throw SYNTAX "Invalid app name \"$name\""
        }

        if {$name in $info(apps)} {
            throw SYNTAX "App name \"$name\" appears more than once in project.kite."
        }

        # NEXT, get the options
        set apptype kit
        set gui     0

        foroption opt args -all {
            -apptype {
                set apptype [lshift args]

                if {$apptype ni {kit exe}} {
                    throw SYNTAX \
                        "Invalid -apptype: \"$apptype\""
                }
            }
            -gui {
                set gui 1
            }
        }


        lappend info(apps)          $name
        set     info(apptype-$name) $apptype
        set     info(gui-$name)     $gui
    }

    # add app name ?options?
    #
    # name    - The app name
    # Options - As for AppCmd
    #
    # Adds another app to the existing project info.

    typemethod {add app} {name args} {
        try {
            AppCmd $name {*}$args
        } trap SYNTAX {result} {
            throw FATAL $result
        }
    }

    # ProvideCmd name args
    #
    # name   - The name of the library package and its directory.
    #          E.g., "kiteutils".
    #
    # Options:
    #
    #    -binary    - The package isn't pure-Tcl.
    #
    # Implementation of the "lib" kite file command.  

    proc ProvideCmd {name args} {
        # FIRST, get the name.
        set name [string trim $name]

        if {![regexp {^[a-zA-Z]\w*$} $name]} {
            throw SYNTAX "Invalid lib name \"$name\""
        }

        if {$name in $info(provides)} {
            throw SYNTAX "Duplicate lib name \"$name\""
        }

        # NEXT, get the options
        set binary 0

        foroption opt args -all {
            -binary { set binary 1 }
        }


        lappend info(provides)     $name
        set     info(binary-$name) $binary
    }

    # add lib name ?options?
    #
    # name    - The lib name
    # Options - As for ProvideCmd
    #
    # Adds another lib to the existing project info.

    typemethod {add lib} {name args} {
        try {
            ProvideCmd $name {*}$args
        } trap SYNTAX {result} {
            throw FATAL $result
        }
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

    # RequireCmd name version ?options?
    #
    # name      - The name of the teapot package
    # version   - The version number of the teapot package
    # options   - Any options.
    #
    # Options:
    #    -local   - If so, the project is locally built, and cannot
    #               be retrieved from the ActiveState teapot.
    #
    # States that the project depends on the given package from 
    # a teapot repository.

    proc RequireCmd {name version args} {
        if {$name in [concat $info(includes) $info(requires)]} {
            throw SYNTAX "Duplicate include/require name: \"$name\""
        }

        dict set rdict version $version
        dict set rdict local   0

        while {[llength $args] > 0} {
            set opt [lshift args]
            switch -exact -- $opt {
                -local { 
                    dict set rdict local 1
                }

                default {
                    throw SYNTAX "Unknown option: \"$opt\""
                }
            }
        }

        ladd info(requires) $name
        set info(require-$name) $rdict
    }

    # SrcCmd name ?options...?
    #
    # name   - The name of the src/* directory
    #
    # Options:
    #
    #   -build script  - Shell script to build contents.
    #   -clean script  - Shell script to clean contents.
    #
    # Implementation of the "src" kite file command.  Specifies the
    # name of a src/<name> directory.  Kite assumes the directory contains
    # a Makefile; however, the project can customize the build and clean
    # scripts.

    proc SrcCmd {name args} {
        # FIRST, get the name.
        set name [string trim $name]

        if {![regexp {^[a-zA-Z]\w*$} $name]} {
            throw SYNTAX "Invalid src directory name \"$name\""
        }

        if {$name in $info(srcs)} {
            throw SYNTAX "Duplicate src directory \"$dir\""
        }

        # NEXT, get the options
        set info(build-$name) "make clean all"
        set info(clean-$name) "make clean"

        foroption opt args {
            -build { set info(build-$name) [lshift args] }
            -clean { set info(clean-$name) [lshift args] }
        }

        lappend info(srcs) $name
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
    # Saving project.kite with current metadata.

    typemethod {kitefile save} {} {
        # FIRST, build up the contents.
        set script [list]

        lappend script \
            "# project.kite" \
            [list project $info(name) $info(version) $info(description)]

        if {$info(poc) ne ""} {
            lappend script [list poc $info(poc)]
        }
            
        
        if {[llength $info(apps)] > 0} {
            lappend script "" "# Applications"

            foreach name $info(apps) {
                set item [list app $name -apptype $info(apptype-$name)]

                if {$info(gui-$name)} {
                    lappend item -gui
                }

                lappend script $item
            }
        }

        if {[llength $info(provides)] > 0} {
            lappend script "" "# Provided Libraries"

            foreach name $info(provides) {
                set item [list provide $name]

                if {$info(binary-$name)} {
                    lappend item -binary
                }

                lappend script $item
            }
        }

        if {[llength $info(srcs)] > 0} {
            lappend script "" "# Compiled Directories"

            foreach name $info(srcs) {
                set item [list src $name]

                if {$info(build-$name) ne $defaultBuild} {
                    lappend item -build $info(build-$name)
                }

                if {$info(clean-$name) ne $defaultClean} {
                    lappend item -clean $info(clean-$name)
                }

                lappend script $item
            }
        }

        if {[llength $info(requires)] > 0} {
            lappend script "" "# External Dependencies"

            foreach name $info(requires) {
                dict with info(require-$name) {
                    set item [list require $name $version]

                    if {$local} {
                        lappend item -local
                    }
                }

                lappend script $item
            }
        }

        if {[llength $info(includes)] > 0} {
            lappend script "" "# Included Projects"

            foreach name $info(includes) {
                dict with info(include-$name) {
                    set item [list include $name $vcs $url $tag]
                }

                lappend script $item
            }
        }

        if {$info(shell) ne ""} {
            lappend script "" "# Shell Initialization"
            lappend script [list shell $info(shell)]
        }

        lappend script ""

        # NEXT, write it all out.
        try {
            file copy -force \
                [project root project.kite] \
                [project root project.bak]
            writefile [project root project.kite] [join $script \n]
        } on error {result} {
            throw FATAL "Could not save new project.kite:\n$result"
        }
    }
    

    #-------------------------------------------------------------------
    # Saving project metadata for use by the project's own code.

    # metadata save
    #
    # Saves the project metadata to disk as appropriate.

    typemethod {metadata save} {} {
        # FIRST, if there's an app save the kiteinfo package for
        # its use.
        if {[llength $info(apps)] > 0} {
            subtree kiteinfo [array get info]
        }

        # NEXT, for each library in $root/lib, update its version number
        # and requirements in the pkgIndex and pkgModules files.
        # Packages can opt out by removing the "-kite" tags.
        foreach lib [$type globdirs lib *] {
            UpdateLibMetadata [file tail $lib]
        }
    }

    # UpdateLibMetadata lib
    #
    # lib   - Name of a library package
    #
    # Updates the version number and requires in the pkgIndex.tcl and 
    # pkgModules.tcl files for the given library.

    proc UpdateLibMetadata {lib} {
        try {
            # FIRST, pkgIndex.tcl
            set fname [project root lib $lib pkgIndex.tcl]

            if {[file exists $fname]} {
                set oldText [readfile $fname]
                set content "package ifneeded $lib $info(pkgversion) "
                append content \
                    {[list source [file join $dir pkgModules.tcl]]}

                set newText [blockreplace $oldText ifneeded $content]

                writefile $fname $newText -ifchanged
            }

            # NEXT, pkgModules.tcl
            set fname [project root lib $lib pkgModules.tcl]

            if {[file exists $fname]} {
                # FIRST, update "package provide".
                set text1 [readfile $fname]
                set content "package provide $lib $info(pkgversion)"
                set text2 [blockreplace $text1 provide $content]

                # NEXT, update "package require"
                set newlines [list]
                foreach line [blocklines $text2 require] {
                    lappend newlines [UpdateRequireLine $line]
                }

                set content [join $newlines \n]
                set text3 [blockreplace $text2 require $content]
                writefile $fname $text3 -ifchanged
            }
        } trap POSIX {result} {
            throw FATAL "Error updating \"$lib\" version: $result"
        }
    }

    # UpdateRequireLine line
    #
    # line   - A line of text in a "require" block.
    #
    # Replaces "package require" versions with correct versions.

    proc UpdateRequireLine {line} {
        # FIRST, get the leader, and normalize the line.
        regexp {^\s*} $line leader
        set input [normalize $line]

        # NEXT, is it a package require line?
        if {![string match "package require *" $input]} {
            return $line
        } else {
            set newline "${leader}package require "
        }

        # NEXT, is there a "-exact"?
        set input [lrange [split $input] 2 end]
        set exact 0

        if {[lindex $input 0] eq "-exact"} {
            set exact 1
            lshift input
        }

        # NEXT, what package is it?
        set pkg [lshift input]

        if {$pkg in [project require names]} {
            if {$exact} {
                append newline "-exact "
            }
            append newline "$pkg "

            append newline [project require version $pkg]
        } elseif {$pkg in [project provide names]} {
            append newline "-exact $pkg [project version]"
        } else {
            set newline $line
        }

        return $newline
    }

    #-------------------------------------------------------------------
    # Metadata Dump
    

    # dumpinfo
    #
    # Dump the project info to stdout.

    typemethod dumpinfo {} {
        puts "Project Information:\n"

        DumpValue "Name:"        $info(name)
        DumpValue "Version:"     $info(version)
        DumpValue "Description:" $info(description)
        puts ""

        if {[llength $info(apps)] == 0} {
            DumpValue "App:" "n/a"
        } else {
            foreach app $info(apps) {
                if {$info(gui-$app)} {
                    set label "GUI App:"
                } else {
                    set label "Console App:"
                }

                set apptext "$app ($info(apptype-$app))"
                DumpValue $label $apptext
            }

            puts ""
        }

        if {[llength $info(provides)] == 0} {
            DumpValue "Provides:" "n/a"
        } else {
            foreach name $info(provides) {
                if {[project provide binary $name]} {
                    set tag "(Binary)"
                } else {
                    set tag "(Pure TCL)"
                }

                DumpValue "Provides:" "${name}(n)" $tag
            }
            puts ""
        }

        if {[llength $info(srcs)] == 0} {
            DumpValue "Makes:" "n/a"
        } else {
            foreach name $info(srcs) {
                DumpValue "Makes:" src/$name
            }
            puts ""
        }

        if {[llength $info(includes)] == 0} {
            DumpValue "Includes:" "n/a"
        } else {
            foreach name $info(includes) {
                array set d $info(include-$name)
                DumpValue "Include:"  "$name as $d(vcs) $d(url) $d(tag)"
            }
            puts ""
        }

        if {[llength $info(requires)] == 0} {
            DumpValue "Requires:" "n/a"
        } else {    
            foreach name $info(requires) {
                array set d $info(require-$name)

                if {$d(local)} {
                    set where "(Locally built)"
                } else {
                    set where "(External)"
                }

                DumpValue "Requires:"  "$name $d(version)" $where
            }
        }
    }

    # DumpValue name value ?tag?
    #
    # name   - The label, include colon
    # value  - The value to dump
    # tag    - Additional data.
    #
    # Writes a row with the name and value in two columns.  If
    # the value is "", then "n/a" is output.

    proc DumpValue {name value {tag ""}} {
        set fmt "%-12s %-20s %s"

        if {$value eq ""} {
            set value "n/a"
        }

        puts [format $fmt $name $value $tag]
    }
    
}





