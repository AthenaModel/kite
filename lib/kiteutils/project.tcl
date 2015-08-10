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

    # Default man page sections
    typevariable defaultMansecs {
        1 "Executables"
        5 "File Formats"
        i "Tcl Interfaces"
        n "Tcl Commands"
    }

    # Build tools

    typevariable tools {
        add
        build
        clean
        compile
        deps
        dist
        docs
        install
        new
        test
        wrap
    }

    #-------------------------------------------------------------------
    # Type variables

    # The project's root directory

    typevariable rootdir ""

    # info - the project info array
    #
    #   name           - The project name
    #   version        - The version number, x.y.z
    #   description    - The project title
    #   poc            - Point-of-contact e-mail address
    #   shell          - Shell initialization script for "kite shell -plain"
    #
    #   apps           - List of project app names, or "" if none.
    #   apptype-$app   - kit or exe
    #   gui-$app       - 1 or 0
    #   icon-$app      - Name of icon file, relative to <root>
    #   force-$app     - Include -force when building tclapp
    #   exclude-$app   - List of names of project requires to exclude from
    #                    this app when building executable.
    #
    #   provides       - List of provided library package names
    #   binary-$name   - 1 if package is binary, and 0 otherwise.
    #
    #   requires       - Names of required teapot packages
    #   reqver-$name   - Version of required package $name
    #   local-$name    - 1 if this is a local package, and 0 otherwise.
    #
    #   srcs           - Names of "src" targets
    #   build-$src     - Script to build contents of $src
    #   clean-$src     - Script to clean contents of $src
    #
    #   xfiles         - Paths of xfile links, relative to <root>,
    #                    using "/" as path separator.
    #   url-$xfile     - URL associated with xfile link.
    #
    #   dists          - Names of distribution targets.
    #   distpat-$dist  - List of path patterns for $dist.
    #
    #   before-$tool   - List of scripts to execute before executing the 
    #                    build tool.
    #   after-$tool    - List of scripts to execute after executing the 
    #                    build tool.
    #
    #   mansecs        - List of manpage section tags
    #   mansec-$tag    - title of the manpage section given the tag.
    #
    # If values are "", the data has not yet been loaded.

    typevariable info -array {
        name           ""
        version        ""
        description    ""
        poc            ""
        apps           ""
        provides       {}
        requires       {}
        srcs           {}
        xfiles         {}
        dists          {}
        shell          {}
        mansecs        {}
    }

    #-------------------------------------------------------------------
    # File and Directory Queries

    # root ?names...?
    #
    # Find and return the directory containing the project.kite file, which
    # by definition is the top directory for the project.  Cache the
    # name for later.  If "names..." are given, join them to the 
    # dir name and return that.
    #
    # Returns "" if the project directory cannot be found.

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
    # Metadata Queries: General

    # getinfo
    #
    # Returns a raw dictionary of all project metadata.  Note that
    # this format can change without notice!

    typemethod getinfo {} {
        return [array get info]
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

    # name
    #
    # Returns the project name.

    typemethod name {} {
        return $info(name)
    }

    # version
    #
    # Returns the project version string.

    typemethod version {} {
        return $info(version)
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
        return [list [project root lib]]
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
    # Metadata Query: Applications
    
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

    # app icon app
    #
    # app - The application name
    #
    # Returns the app's icon file name, or "".

    typemethod {app icon} {app} {
        return $info(icon-$app)
    }

    # app exclude app
    #
    # app - The application name
    #
    # Returns the -exclude list of package names for this app.

    typemethod {app exclude} {app} {
        return $info(exclude-$app)
    }

    # app force app
    #
    # app - The application name
    #
    # Returns 1 if the -force flag was given, and 0 otherwise.

    typemethod {app force} {app} {
        return $info(force-$app)
    }

    # app loader app
    #
    # app - The application name
    #
    # Returns the project's application loader script.

    typemethod {app loader} {app} {
        return [project root bin $app.tcl]
    }

    # app binfile app
    #
    # app - The application name
    #
    # Returns the app's executable file, given its app type and
    # the platform, as built in the project bin directory.

    typemethod {app binfile} {app} {
        if {[project app apptype $app] eq "kit"} {
            return $app-[project version]-tcl.kit
        } elseif {[project app apptype $app] eq "exe"} {
            return [os exefile $app-[project version]-[platform::identify]]
        } else {
            error "Unknown application type"
        }
    }

    # app installfile app
    #
    # app - The application name
    #
    # Returns the name of the application file as it is installed into 
    # the user's ~/bin directory.

    typemethod {app installfile} {app} {
        if {[project app apptype $app] eq "kit"} {
            return $app
        } else {
            return [os exefile $app]
        }
    }

    #-------------------------------------------------------------------
    # Metadata Query: Provided Libraries

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

    # provide zipfile name
    #
    # name - The name of the library's teapot .zip package on this
    # platform.

    typemethod {provide zipfile} {name} {
        set ver [project version]
        
        if {[project provide binary $name]} {
            set plat [platform::identify]
        } else {
            set plat "tcl"
        }

        return "package-$name-$ver-$plat.zip"
    }

    #-------------------------------------------------------------------
    # Metadata Query: Required Packages    

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
        return $info(reqver-$name)
    }

    # require islocal name
    #
    # name  - the require name
    #
    # Returns 1 if the required package is internally built.

    typemethod {require islocal} {name} {
        return $info(local-$name)
    }

    #-------------------------------------------------------------------
    # Metadata Query: Source Directories

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

    #-------------------------------------------------------------------
    # Metadata query: eXternal Files

    # xfile paths
    #
    # Returns a list of the xfile path names.

    typemethod {xfile paths} {} {
        return $info(xfiles)
    }

    # xfile url path
    #
    # path   - Project path for an xfile
    #
    # Returns the URL associated with the path.

    typemethod {xfile url} {path} {
        return $info(url-$path)
    }

    #-------------------------------------------------------------------
    # Metadata Query: Distributions

    # dist names
    #
    # Returns the list of "dist" target names.

    typemethod {dist names} {} {
        return $info(dists)
    }

    # dist patterns dist
    #
    # dist  - A dist target name, as returned by [project dist names]
    # 
    # Returns the list of file patterns.

    typemethod {dist patterns} {dist} {
        return $info(distpat-$dist)
    }

    # dist files dist
    #
    # dist  - A dist target name, as returned by [project dist names]
    #
    # Returns a dictionary of files in the named distribution; the key
    # is the relative path for the .zip file and the value is the 
    # absolute path of the source file.

    typemethod {dist files} {dist} {
        # FIRST, get the files that match the dist patterns.
        set patterns $info(distpat-$dist)

        set trans(counter) 0

        set dict [dict create]
        while {[got $patterns]} {
            set pattern [lshift patterns]

            switch -exact -- $pattern {
                %apps   { set newdict [GetDistApps]                  }
                %libs   { set newdict [GetDistLibs]                  }
                %get    { set newdict [GetDistURL [lshift patterns]] }
                default { set newdict [GetDistFiles $pattern]        }
            }

            set dict [dict merge $dict $newdict]
        }

        return $dict
    }

    # dist expand dist
    #
    # dist  - The distribution name
    #
    # Returns the distribution name with %-patterns expanded.

    typemethod {dist expand} {dist} {
        set map [list %platform [platform::identify]]
        return [string map $map [string trim $dist]]
    }

    # dist zipfile dist
    #
    # dist  - A dist target name, as returned by [project dist names]
    # 
    # Returns the name of the distribution zipfile.

    typemethod {dist zipfile} {dist} {
        set fullname [$type dist expand $dist]
        return "[project name]-[project version]-$fullname.zip"       
    }

    # GetDistApps 
    #
    # Gets a dictionary of the as-built names of the project's 
    # applications, by destination path.

    proc GetDistApps {} {
        set dict [dict create]
        foreach name [project app names] {
            set filename [project root bin [project app binfile $name]]
            if {[file isfile $filename]} {
                dict set dict bin/[file tail $filename] $filename
            }
        }

        return $dict
    }

    # GetDistLibs 
    #
    # Gets a dictionary of the library packages by destination path.

    proc GetDistLibs {} {
        set dict [dict create]
        set pattern "package-*-[project version]-*.zip"

        foreach name [project globfiles .kite libzips $pattern] {
            set dfile lib/[file tail $name]
            dict set dict $dfile $name 
        }

        return $dict
    }

    # GetDistURL pair
    #
    # pair  - a dfile/URL pair.
    #
    # Plucks the document at the URL, and returns an fdict.

    proc GetDistURL {pair} {
        lassign $pair dfile url
        set f [file tempfile pfile]
        close $f

        try {
            pluck file $pfile $url
        } trap NOTFOUND {result} {
            throw FATAL [outdent "
                Could not %get file \"$dfile\" from URL:
                $url
                => $result
            "]
        }

        return [dict create $dfile $pfile]
    }

    # GetDistFiles pattern
    #
    # Gets arbitrary files given a glob pattern and returns a dictionary
    # of file paths by destination path.

    proc GetDistFiles {pattern} {
        set dict [dict create]

        foreach filename [project globfiles {*}[split $pattern /]] {
            dict set dict [Unroot $filename] $filename
        }

        return $dict
    } 

    # Unroot filename
    #
    # filename  - Absolute path to a project file
    #
    # Removes the absolute project root.

    proc Unroot {filename} {
        set slen [string length [project root]]
        set relfile [string replace $filename 0 $slen]

        return $relfile
    }


    #-------------------------------------------------------------------
    # Hook Introspection

    # hook when tool
    #
    # when   - before | after
    # tool  - One of the build tools
    #
    # Returns the list of scripts that are executed before or after the
    # given tool.  Returns the empty list if there are no hooks for
    # the given tool.
    typemethod hook {when tool} {
        require {$when in {before after}} "Invalid when"

        if {$tool in $tools && [info exists info($when-$tool)]} {
            return $info($when-$tool)
        }

        return [list]
    }
    
    # hooks 
    #
    # Returns a flat list of pairs identifying the hooks for which
    # scripts have been defined, e.g., "before compile after docs..."
    typemethod hooks {} {
        set result [list]

        foreach tool $tools {
            foreach when {before after} {
                if {[info exists info($when-$tool)] &&
                    [llength $info($when-$tool)] > 0
                } {
                    lappend result $when $tool
                }
            }
        }

        return $result
    }

    #-------------------------------------------------------------------
    # Man Page Section Introspection

    # mansec section
    #
    # section  - A section tag
    #
    # Returns the section title.

    typemethod mansec {section} {
        return $info(mansec-$section)
    }

    # mansecs
    #
    # Returns the list of man page section tags

    typemethod mansecs {} {
        return $info(mansecs)
    }

    #-------------------------------------------------------------------
    # Reading the information from the project file.

    # load
    #
    # Loads the information from the project file.  We must be
    # in a project tree.

    typemethod load {} {
        # FIRST, initialize defaults.
        dict for {section title} $defaultMansecs {
            lappend info(mansecs) $section
            set info(mansec-$section) $title
        }

        # NEXT, set up the safe interpreter
        # TODO: Use a smartinterp(n).
        set safe [interp create -safe]
        $safe alias project [myproc ProjectCmd]
        $safe alias poc     [myproc PocCmd]
        $safe alias app     [myproc AppCmd]
        $safe alias provide [myproc ProvideCmd]
        $safe alias require [myproc RequireCmd]
        $safe alias src     [myproc SrcCmd]
        $safe alias xfile   [myproc XfileCmd]
        $safe alias dist    [myproc DistCmd]
        $safe alias shell   [myproc ShellCmd]
        $safe alias after   [myproc ToolHookCmd] after
        $safe alias before  [myproc ToolHookCmd] before
        $safe alias mansec  [myproc MansecCmd]

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
        set exclude [list]
        set force   0
        set gui     0
        set icon    ""

        foroption opt args -all {
            -apptype {
                set apptype [lshift args]

                if {$apptype ni {kit exe}} {
                    throw SYNTAX \
                        "Invalid -apptype: \"$apptype\""
                }
            }
            -exclude {
                set exclude [lshift args]
                if {![string is list $exclude]} {
                    throw SYNTAX \
                        "Invalid -exclude: \"$exclude\""
                }
            }
            -force {
                set force 1
            }
            -gui {
                set gui 1
            }
            -icon {
                set icon [lshift args]
            }
        }


        lappend info(apps)          $name
        set     info(apptype-$name) $apptype
        set     info(exclude-$name) $exclude
        set     info(force-$name)   $force
        set     info(gui-$name)     $gui
        set     info(icon-$name)    $icon
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
        if {$name in $info(requires)} {
            throw SYNTAX "Duplicate require name: \"$name\""
        }

        set local 0

        foroption opt args {
            -local { set local 1 }
        }

        ladd info(requires)    $name
        set info(reqver-$name) $version
        set info(local-$name)  $local
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

    # XfileCmd path url
    #
    # path   - The local path of the external file
    # url    - The URL from which the external file can be retrieved.
    #
    # Directs Kite to grab the file at the URL and save it into the
    # project tree at [project root $path].  This will happen at
    # 'kite xfiles update' or 'kite build all'.
    #
    # The path should be a path relative to the project root, written
    # with forward slashes, and including the local file name.
    #
    # The URL should be an HTTP or HTTPS URL.

    proc XfileCmd {path url} {
        # FIRST, get the name.
        prepare path
        prepare url

        lappend info(xfiles) $path
        set info(url-$path) $url
    }

    # DistCmd name patterns
    #
    # name     - The name of the distribution target, e.g., "install".
    # patterns - List of path patterns for files to include.
    #
    # Implementation of the "dist" kite file command.  

    proc DistCmd {name patterns} {
        # FIRST, get the name.
        if {![regexp {^[a-zA-Z][-[:alnum:]%_.]*$} $name]} {
            throw SYNTAX "Invalid distribution name \"$name\""
        }

        if {$name in $info(dists)} {
            throw SYNTAX "Duplicate distribution name \"$name\""
        }

        lappend info(dists)         $name
        set     info(distpat-$name) $patterns
    }


    # ShellCmd script
    #
    # Implementation of the "shell" kite file command.

    proc ShellCmd {script} {
        set info(shell) $script
    }

    # ToolHookCmd when tool script
    #
    # when   - before|after
    # tool  - One of the "tools"
    # script - A user script
    #
    # Implementation of the "after" and "before" kite file commands.

    proc ToolHookCmd {when tool script} {
        if {$tool ni $tools} {
            throw SYNTAX "Invalid tool in '$when': \"$tool\""
        }
        lappend info($when-$tool) $script
    }

    # MansecCmd section title
    #
    # section   - The man page section tag
    # title     - The section's title
    #
    # Notes that the project has the given man page section.  Also
    # can be used to change the title of a default section.

    proc MansecCmd {section title} {
        set section [string tolower $section]
        if {![Mansec? $section]} {
            throw SYNTAX "Invalid manpage section number: \"$section\""
        }

        ladd info(mansecs) $section
        set info(mansec-$section) $title
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
    # ver   - A Tcl version number, e.g, 1.2.3 or 1.2.3b2
    #
    # Validates the version, which must be a valid Tcl package 
    # version number.

    proc Version? {ver} {
        return [regexp {^(\d+[.])*\d+[.ab]\d+$} $ver]
    }

    # Mansec? name
    #
    # name   - A manpage section tag.
    #
    # Validates the name; it may contain letters and numbers.

    proc Mansec? {name} {
        return [regexp {^[[:alnum:]]+$} $name]
    }

    #-------------------------------------------------------------------
    # Saving project.kite with current metadata.

    # new name ?description?
    #
    # name        - A project name
    # description - The project's description.
    #
    # Creates a new project root directory with the given name, and 
    # CD's into it.  Sets the initial project metadata.

    typemethod new {name {description "Your project description"}} {
        set rootdir [file join [pwd] $name]
        file mkdir $rootdir
        cd $rootdir

        set info(name)        $name
        set info(version)     "0.0.0a0"
        set info(description) $description

        project save
        project load
    }


    typemethod save {} {
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

                if {$info(icon-$name) ne ""} {
                    lappend item -icon $info(icon-$name)
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


        # Man page sections: Output if new or modified
        set mansecs {}
        foreach sec $info(mansecs) {
            if {![dict exists $defaultMansecs $sec] ||
                [dict get $defaultMansecs $sec] ne $info(mansec-$sec)
            } {
                lappend mansecs $sec
            }
        }

        if {[llength $mansecs] > 0} {
            lappend script "" "# Man Page Sections"
            foreach sec $mansecs {
                lappend script [list mansec $sec $info(mansec-$sec)]
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
                set item [list require $name $info(reqver-$name)]

                if {$info(local-$name)} {
                    lappend item -local
                }

                lappend script $item
            }
        }

        if {$info(xfiles) ne ""} {
            lappend script "" "# External Files"
            foreach path $info(xfiles) {
                lappend script [list xfile $path $info(url-$path)]
            }
        }

        if {$info(dists) ne ""} {
            lappend script "" "# Distribution Targets"
            foreach name $info(dists) {
                lappend script [list dist $name $info(distpat-$name)]
            }
        }

        if {$info(shell) ne ""} {
            lappend script "" "# Shell Initialization"
            lappend script [list shell $info(shell)]
        }

        set hooks [$type hooks]

        if {[llength $hooks] > 0} {
            lappend script "" "# Tool Hooks"
            foreach {when tool} $hooks {
                foreach hook [$type hook $when $tool] {
                    lappend script [list $when $tool $hook]
                    lappend script ""                
                }
            }
        }

        lappend script ""

        # NEXT, write it all out.
        try {
            if {[file exists [project root project.kite]]} {
                file copy -force \
                    [project root project.kite] \
                    [project root project.bak]
            }
            writefile [project root project.kite] [join $script \n]
        } on error {result} {
            throw FATAL "Could not save new project.kite:\n$result"
        }
    }
}





