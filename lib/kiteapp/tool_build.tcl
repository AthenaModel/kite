#-----------------------------------------------------------------------
# TITLE:
#   tool_build.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "build" tool.  By default, this builds all of the build 
#   targets: The app or appkit (if any), teapot packages, docs, and
#   other build targets specified in project.kite.
#
# TODO: Move basekit-finding code to plat.tcl.
# TODO: Generate libzips directly, using zipfile::encode.
# TODO: tclapp.tcl tclapp proxy?
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::BUILD

tool define build {
    usage       {0 - "?all|app|lib? ?<name>...?"}
    description "Build the entire project."
    needstree      yes
} {
    The 'kite build' tool builds all build targets specified in the
    project's project.kite file.  In particular:

    * Libs are built as .kite/libzips/package-<name>*.zip.
    * Apps are built as bin/<name>[.exe] or bin/<name>.kit

    kite build
        By default, 'kite build' builds all libraries and applications.

    kite build lib ?<name>...?
        Builds all libraries 'provide'd in project.kite, or optionally
        just those that are named on the command line.

    kite build app ?<name>...?
        Builds all applications listed in project.kite, or optionally
        just those that are named on the command line.

    kite build all
        The previous commands are for day-to-day use.  This command is
        for performing complete builds of the entire project.  It 
        is equivalent to:

            kite compile
            kite test
            kite docs
            kite build lib
            kite build app
            kite dist

        This command will halt if the external dependencies are not 
        up to date, or if an error occurs at any step of the process.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, get the arguments.
        set kind [lshift argv]

        if {$kind ni {"" lib app all}} {
            throw FATAL "Invalid build type: \"$kind\"."
        }

        # FIRST, check for dependencies.
        set upToDate [deps uptodate]

        if {$upToDate} {
            puts "All external dependencies are up to date."
            puts ""
        } else {
            puts "WARNING: Some dependencies are not up-to-date."
            puts "Run \"kite deps\" for details."
            puts ""
        }

        if {$kind eq "all"} {
            if {[llength $argv] > 0} {
                throw FATAL "Usage: kite build all"
            }

            if {!$upToDate} {
                throw FATAL [outdent {
                    Please resolve the out-of-date dependencies before
                    using 'kite build all'
                }]
            }

            # NEXT, build everything, halting on any error.

            if {[got [project src names]]} {
                header "Compiling src directories"
                tool use compile
            }

            if {[got [project globdirs test *]]} {
                header "Running project tests."
                tool use test
            }

            if {[got [project globfiles docs *.ehtml]]     ||
                [got [project globfiles docs * *.ehtml]]   ||
                [got [project globfiles docs * * *.ehtml]]
            } {
                header "Building project documentation"
                tool use docs
            }

            if {[got [project provide names]]} {
                header "Building library teapot packages"
                BuildLibs {}
            }
                
            if {[got [project app names]]} {
                header "Building applications"
                BuildApps {}
            }

            if {[got [project dist names]]} {
                header "Building distributions"
                tool use dist
            }
            return
        }


        # NEXT, Build provided libraries as teapot packages.
        if {$kind in {lib ""}} {
            BuildLibs $argv
        }

        # NEXT, Build applications.
        if {$kind in {app ""}} {
            BuildApps $argv
        }
    }
    
    # header text
    #
    # text   - header text string
    #
    # Outputs a header.

    proc header {text} {
        puts ""
        puts [string repeat = 75]
        puts $text
        puts ""
    }

    #-------------------------------------------------------------------
    # Building Apps

    # BuildApps apps
    #
    # apps  - list of app names, or "" for all.

    proc BuildApps {apps} {
        if {[llength $apps] == 0} {
            set apps [project app names]
        }

        foreach app $apps {
            if {$app ni [project app names]} {
                # Note: This cannot happen with 'kite build all'.
                puts "WARNING, Unknown application: \"$app\""

                continue
            }
            BuildApp $app
        }
    }

    # BuildApp app
    #
    # app   - The name of an app
    #
    # Builds the app.

    proc BuildApp {app} {
        # FIRST, get relevant data
        set main    [project app loader $app]
        set exefile [project app exefile $app]
        set exepath [project root bin $exefile]

        # NEXT, do we have the main script
        if {![file exists $main]} {
            throw fatal \
                "Cannot build app '$app'; the 'bin/$app.tcl script is missing."
        }

        # NEXT, erase the existing app, if any
        if {[file exists $exepath]} {
            vputs "Deleting old $exefile"
            catch {file delete -force $exepath}
        }

        # NEXT, get the basekit, if any.
        if {[project app apptype $app] eq "exe"} {
            set basekit [FindBaseKit [project app gui]]
        } else {
            set basekit ""
        }

        # NEXT, begin to build up the command.
        set command [TclAppCommand $app $exepath $basekit]

        # NEXT, prepare to write logfile.
        set logfile [project root .kite build_$app.log]
        file mkdir [file dirname $logfile]

        lappend command \
            >&  $logfile

        # NEXT, Build the app

        puts "Building $app as '$exepath'"
        puts "See $logfile for details.\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building $exefile; see $logfile:\n$result"
        }
    }

    # TclAppCommand app target basekit
    #
    # app      - The name of the app
    # target   - The name of the output file.
    # basekit  - The name of the basekit, or ""
    #
    # Returns the base tclapp command for building apps and app kits.

    proc TclAppCommand {app target basekit} {
        lappend command                 \
            -ignorestderr --            \
            tclapp [project app loader $app] \
            [project root lib * *]

        # NEXT, include library subdirectories, if any.
        if {[llength [glob -nocomplain [project root lib * * *]]] > 0} {
            lappend command [project root lib * * *]
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
    # Building Teapot .zip files

    # BuildLibs libs
    #
    # libs   - List of libs to build, or "" for all

    proc BuildLibs {libs} {
        if {[llength $libs] == 0} {
            set libs [project provide names]
        }

        foreach lib $libs {
            if {$lib ni [project provide names]} {
                # This cannot happen with 'kite build all'.
                puts "WARNING, Unknown library: \"$lib\""
                continue
            }
            BuildTeapotZip $lib
        }
    }

    # BuildTeapotZip lib
    #
    # lib   - A "lib" from project.kite
    #
    # Builds a .zip package for the lib.

    proc BuildTeapotZip {lib} {
        # FIRST, make sure the library package exists.
        puts "Building teapot package: $lib [project version]"
        set libdir [project root lib $lib]
        if {![file isdirectory $libdir]} {
            puts [outdent "
                WARNING: Kite could not build a teapot .zip file for
                library \"$lib\", because the library package was not
                not found at $libdir.
            "]
            return
        }

        # NEXT, create its teapot.txt file
        #
        # TODO: Get external project requires from the lib's 
        # pkgModules.tcl file, and add
        #
        #    Meta require {$package $version}
        #
        # to the teapot.txt

        if {[project provide binary $lib]} {
            set plat [platform::identify]
        } else {
            set plat "tcl"
        }

        set contents "Package $lib [project version]\n"                         \

        append contents \
            "Meta description [project name]: [project description]\n" \
            "Meta entrykeep\n"                                         \
            "Meta included *\n"                                        \
            "Meta platform $plat\n"

        writefile [project root lib $lib teapot.txt] $contents

        # NEXT, prepare the build command.
        set zipdir [project zippath]
        lappend command \
            teapot-pkg generate -t zip -o $zipdir $libdir \

        # NEXT, prepare to write logfile.
        set logfile [project root .kite build_lib_$lib.log]
        file mkdir [file dirname $logfile]

        lappend command \
            >&  $logfile

        puts "Building lib $lib"
        puts "See $logfile for details.\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building lib $lib; see $logfile:\n$result"
        }
    }
    

    #-------------------------------------------------------------------
    # Helpers

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
    

    #-------------------------------------------------------------------
    # Clean up

    # clean
    #
    # Cleans up all build products produced by this tool.

    typemethod clean {} {
        # FIRST, clean up lib .zips.
        clean "Cleaning library teapot .zip files..." \
            .kite/libzips/*.zip


        # NEXT, clean up applications
        set apps [getapps]

        if {[got $apps]} {
            puts "Cleaning application executables..."
            foreach app $apps {
                file delete -force $app
            }
        }
    }

    # getapps 
    #
    # Gets a dictionary of the as-built names of the project's 
    # applications, by destination path.
    #
    # TODO: This duplicates code in disttool.  Figure out a good place
    # to put this.

    proc getapps {} {
        foreach name [project app names] {
            lappend result [project root bin [project app exefile $name]]
        }

        return $result
    }
}






