#-----------------------------------------------------------------------
# TITLE:
#   buildtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "build" tool.  By default, this builds all of the build 
#   targets: The app or appkit (if any), teapot packages, docs, and
#   other build targets specified in project.kite.
#
#   TODO: When we actually have more than one kind of build product,
#   add arguments so that the user can selectively build just one thing.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(build) {
    arglist     {}
    package     ktools
    ensemble    ::ktools::buildtool
    description "Build the entire project."
    intree      yes
}

set ::khelp(build) {
    The "build" tool builds all build targets specified in the
    project's project.kite file.  In particular:

    * Apps will be built as bin/<name>[.exe]
    * Appkits will be built as bin/<name>.kit

    Build also builds the man pages and documentation.
}

#-----------------------------------------------------------------------
# buildtool ensemble

snit::type ::ktools::buildtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Lookup Tables

    # manpage section titles
    #
    # TODO: For non-standard sections, we'll need a way to handle this.

    typevariable manpageSections -array {
        1 "Executables"
        5 "File Formats"
        i "Tcl Interfaces"
        n "Tcl Commands"
    }

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs build 0 0 {} $argv

        # FIRST, check for dependencies.
        if {![includer uptodate] || ![teacup uptodate]} {
            puts "WARNING: Some dependencies are not up-to-date."
            puts "Run \"kite deps\" for details."
            puts ""
        }

        # TODO: Build make targets

        # NEXT, build the app

        if {[project app name] ne ""} {
            set exe [project app get exe]

            switch -exact $exe {
                pack    { BuildAppPack [project app name] }
                kit     { BuildAppKit  [project app name] }
                default { error "Unknown application type: \"$exe\"" }
            }
        }

        # TODO: build teapot packages.

        # NEXT, build documentation if marsutil is present.
        if {[catch {package require marsutil 3.0}]} {
            puts "WARNING: Can't build documentation, marsutil is unavailable."
            return
        }

        BuildManPages
    }
    

    #-------------------------------------------------------------------
    # Building Apps

    # BuildAppKit name
    #
    # name   - The name of an appkit
    #
    # Builds the appkit if possible.  An appkit is a starkit that
    # includes $root/bin/$name.tcl (the main script) and the entire
    # lib/ tree (if any).
    #
    # It is assumed that TclDevKit is installed and accessible, and
    # that kite.kit is using the same tclsh as is being used in 
    # development.

    proc BuildAppKit {name} {
        # FIRST, do we have the main script
        set main [project app loader]

        if {![file exists $main]} {
            throw fatal \
                "Cannot build appkit '$name'; the 'bin/$name.tcl script is missing."
        }

        # NEXT, erase the existing kit, if any
        set kit [project root bin $name.kit]

        if {[file exists $kit]} {
            vputs "Deleting old $name.kit"
            catch {file delete -force $kit}
        }

        # NEXT, begin to build up the command.
        set command [TclAppCommand $kit]

        # NEXT, prepare to write logfile.
        set logfile [project root .kite build_$name.log]
        file mkdir [file dirname $logfile]

        lappend command \
            >&  $logfile

        # NEXT, Build the appkit

        puts "Building $name.kit as '$kit'"
        puts "See $logfile for details.\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building $name.kit; see $logfile:\n$result"
        }
    }

    # BuildAppPack name
    #
    # name   - The name of an app
    #
    # Builds the app if possible.  An app is a starpack that
    # includes $root/bin/$name.tcl (the main script) and the entire
    # lib/ tree (if any), plus includes and requires.
    #
    # It is assumed that TclDevKit is installed and accessible, and
    # that kite.kit is using the same tclsh as is being used in 
    # development.

    proc BuildAppPack {name} {
        # FIRST, do we have the main script
        set main [project app loader]

        if {![file exists $main]} {
            throw fatal \
                "Cannot build app '$name'; the 'bin/$name.tcl script is missing."
        }

        # NEXT, get the executable name.
        set exefile [project app name]

        if {$::tcl_platform(platform) eq "windows"} {
            append exefile .exe
        } 
        set exe [project root bin $exefile]

        # NEXT, get the basekit name.
        set basekit [FindBaseKit [project app get gui]]

        # NEXT, begin to build up the command.
        set command [TclAppCommand $exe $basekit]

        # NEXT, prepare to write logfile.
        set logfile [project root .kite build_$name.log]
        file mkdir [file dirname $logfile]

        lappend command \
            >&  $logfile

        # NEXT, erase the existing exe file, if any

        if {[file exists $exe]} {
            vputs "Deleting old $exefile"
            catch {file delete -force $exe}
        }

        # NEXT, Build the app

        puts "Building $exefile as '$exe'"
        puts "See $logfile for details.\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building $exefile; see $logfile:\n$result"
        }
    }

    # TclAppCommand target ?basekit?
    #
    # target   - The name of the output file.
    # basekit  - The name of the basekit, or ""
    #
    # Returns the base tclapp command for building apps and app kits.

    proc TclAppCommand {target {basekit ""}} {
        lappend command                 \
            -ignorestderr --            \
            tclapp [project app loader] \
            [project root lib * *]

        # NEXT, include library subdirectories, if any.
        if {[llength [glob -nocomplain [project root lib * * *]]] > 0} {
            lappend command [project root lib * * *]
        }

        # NEXT, do we have any includes?
        foreach iname [project include names] {
            set ilib [project root includes $iname lib]

            if {[llength [glob -nocomplain [file join $ilib *]]] > 0} {
                lappend command [file join $ilib * *]
            }

            # NEXT, include library subdirectories, if any.
            if {[llength [glob -nocomplain [file join $ilib * * *]]] > 0} {
                lappend command [file join $ilib * * *]
            }
        }

        # NEXT, add the basekit, if any.
        if {$basekit ne ""} {
            lappend command \
                -basekit $basekit
        }

        # NEXT, other standard arguments.
        lappend command \
            -out     $target          \
            -archive [project teapot]

        # NEXT, add "require" dependencies
        foreach rqmt [project require names] {
            set pkgref "$rqmt [project require version $rqmt]"
            lappend command \
                -pkgref $pkgref
        }

        return $command
    }

    #-------------------------------------------------------------------
    # Build docs

    # BuildManPages
    #
    # Uses marsutil(n)'s manpage(n) to build manpages in all manpage
    # directories.

    proc BuildManPages {} {
        # FIRST, get the manpage directories
        set mandirs [glob -nocomplain [project root docs man*]]

        if {[llength $mandirs] == 0} {
            return
        }

        foreach mandir $mandirs {
            # Skip non-manpage-directories.
            if {![file isdirectory $mandir]} {
                continue
            }

            # NEXT, validate the section number
            # TODO: need to support project-specific sections
            set num [SectionNum [file tail $mandir]]
            
            if {![info exists manpageSections($num)]} {
                throw FATAL "Unknown man page section: \"man$num\""
            }

            # NEXT, process the man pages in the directory.
            try {
                marsutil::manpage format $mandir $mandir \
                    -project     [project name]          \
                    -version     [project version]       \
                    -description [project description]   \
                    -section     "($num) $manpageSections($num)"
            } trap SYNTAX {result} {
                throw FATAL "Syntax error in man page: $result"
            }
        }
    }

    # SectionNum dirname
    #
    # dirname  - A manpage directory, man<num>
    #
    # Extracts the manpage section number.

    proc SectionNum {dirname} {
        return [string range $dirname 3 end]
    }
    

    #-------------------------------------------------------------------
    # Helpers

    # GetTeapotDir
    #
    # For ActiveTcl, the default teapot is in $TCL_HOME/lib/teapot.
    #
    # TODO: Kite should have its own local teapot on the machine.
    # TODO: This routine assumes the default teapot location for
    # Windows only.

    proc GetTeapotDir {} {
        set shell [info nameofexecutable]
        set tclhome [file dirname [file dirname $shell]]
        set teacup [file join $tclhome bin teacup]

        # Assume the default teacup repository
        set result [exec $teacup default]
        return [string trim $result]
    }

    # FindBaseKit gflag
    #
    # gflag  - If 1, we need a Tk base-kit.
    #
    # Finds the basekit executable, based on the platform.

    proc FindBaseKit {gflag} {
        # FIRST, determine the base-kit pattern.
        set tv [info tclversion]

        if {$gflag} {
            set prefix "base-tk${tv}-thread*"
        } else {
            set prefix "base-tcl${tv}-thread*"
        }

        if {$::tcl_platform(platform) eq "windows"} {
            set basedir [file dirname [info nameofexecutable]]
            set pattern [file join $basedir $prefix].exe
        } elseif {$::tcl_platform(os) eq "Darwin"} {
            # OS X
            set basedir "/Library/Tcl/basekits"
            set pattern [file join $basedir $prefix]
        } else {
            # Linux -- Tentative!
            set basedir [file dirname [info nameofexecutable]]
            set pattern [file join $basedir $prefix]
        }

        set allfiles [glob -nocomplain $pattern]

        # NEXT, strip out library files
        foreach file $allfiles {
            if {[file extension $file] in {.dll .dylib .so}} {
                continue
            }

            return $file
        }

        throw FATAL "Could not find basekit."
    }
    
}



