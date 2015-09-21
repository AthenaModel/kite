#-----------------------------------------------------------------------
# TITLE:
#   tool_wrap.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "wrap" tool.  By default, this wraps all of the wrap 
#   targets: The app or appkit (if any), teapot packages, docs, and
#   other wrap targets specified in project.kite.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::WRAP

tool define wrap {
    usage       {0 - "?app|lib? ?<name>...?"}
    description "Wrap the applications and libraries."
    needstree   yes
} {
    The 'kite wrap' tool wraps for deployment all wrap targets 
    specified in the project's project.kite file.  In particular:

    * Libs are wrapped as .kite/libzips/package-<name>*.zip.
    * Apps are wrapped as bin/<name>[.exe] or bin/<name>.kit

    kite wrap
        By default, 'kite wrap' wraps all libraries and applications.

    kite wrap lib ?<name>...?
        Wraps all libraries 'provide'd in project.kite, or optionally
        just those that are named on the command line.

    kite wrap app ?<name>...?
        Wraps all applications listed in project.kite, or optionally
        just those that are named on the command line.

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

        if {$kind ni {"" lib app}} {
            throw FATAL "Invalid wrap type: \"$kind\"."
        }

        # FIRST, check for dependencies.
        puts "Checking external dependencies..."
        set upToDate [deps uptodate]

        if {$upToDate} {
            puts "All external dependencies are up to date."
            puts ""
        } else {
            puts "WARNING: Some dependencies are not up-to-date."
            puts "Run \"kite deps\" for details."
            puts ""
        }


        # NEXT, Wrap provided libraries as teapot packages.
        if {$kind in {lib ""}} {
            WrapLibs $argv
        }

        # NEXT, Wrap applications.
        if {$kind in {app ""}} {
            WrapApps $argv
        }
    }
    
    #-------------------------------------------------------------------
    # Wrapping Apps

    # WrapApps apps
    #
    # apps  - list of app names, or "" for all.

    proc WrapApps {apps} {
        if {[llength $apps] == 0} {
            set apps [project app names]
        }

        foreach app $apps {
            if {$app ni [project app names]} {
                # Note: This cannot happen with 'kite wrap all'.
                puts "WARNING, Unknown application: \"$app\""

                continue
            }
            WrapApp $app
        }
    }

    # WrapApp app
    #
    # app   - The name of an app
    #
    # Wraps the app.

    proc WrapApp {app} {
        # FIRST, get relevant data
        set main    [project app loader $app]
        set exefile [project app binfile $app]
        set exepath [project root bin $exefile]

        # NEXT, do we have the main script
        if {![file exists $main]} {
            throw fatal \
                "Cannot wrap app '$app'; the 'bin/$app.tcl script is missing."
        }

        # NEXT, erase the existing app, if any
        if {[file exists $exepath]} {
            vputs "Deleting old $exefile"
            catch {file delete -force $exepath}
        }

        # NEXT, get the basekit, if any.
        if {[project app apptype $app] eq "exe"} {
            if {[project app gui $app]} {
                set basekit [plat pathto basekit.tk]
            } else {
                set basekit [plat pathto basekit.tcl]
            }
        } else {
            set basekit ""
        }

        # NEXT, begin to wrap up the command.
        set command [TclAppCommand $app $exepath $basekit]

        # NEXT, prepare to write logfile.
        set logfile [project root .kite wrap_$app.log]
        file mkdir [file dirname $logfile]

        writefile $logfile "$command\n\n"

        lappend command \
            >>&  $logfile

        # NEXT, Wrap the app

        puts "Wrapping $app as '$exepath'"
        puts "See $logfile for details.\n"

        try {
            vputs "Command = <$command>"
            cd [project root]
            eval exec $command
        } on error {result} {
            throw FATAL "Error wrapping $exefile; see $logfile:\n$result"
        }
    }

    # TclAppCommand app target basekit
    #
    # app      - The name of the app
    # target   - The name of the output file.
    # basekit  - The name of the basekit, or ""
    #
    # Returns the base tclapp command for wrapping apps and app kits.

    proc TclAppCommand {app target basekit} {
        lappend command                 \
            -ignorestderr --            \
            tclapp [file join bin [file tail [project app loader $app]]] \
            [file join lib * *]

        # NEXT, include library subdirectories, if any.
        if {[llength [glob -nocomplain [project root lib * * *]]] > 0} {
            lappend command [file join lib * * *]
        }

        # NEXT, add the basekit, if any.
        if {$basekit ne ""} {
            lappend command \
                -prefix $basekit
        }

        # NEXT, add the icon, if appropriate
        if {$basekit                ne ""    && 
            [project app icon $app] ne ""    &&
            [os flavor]             ne "osx"
        } {
            lappend command \
                -icon [project app icon $app]
        }

        # NEXT, add options
        lappend command -out $target

        foreach repo [teacup repos] {
            lappend command -archive $repo
        }

        # Follow package requirements
        lappend command -follow 

        # Force wrap if -force was given to app.
        if {[project app force $app]} {
            lappend command -force
        }

        # NEXT, add "require" dependencies
        foreach rqmt [project require names] {
            if {$rqmt ni [project app exclude $app]} {
                set pkgref "$rqmt [project require version $rqmt]"
                lappend command \
                    -pkgref $pkgref
            }
        }

        return $command
    }

    #-------------------------------------------------------------------
    # Wrapping Teapot .zip files

    # WrapLibs libs
    #
    # libs   - List of libs to wrap, or "" for all

    proc WrapLibs {libs} {
        if {[llength $libs] == 0} {
            set libs [project provide names]
        }

        foreach lib $libs {
            if {$lib ni [project provide names]} {
                # This cannot happen with 'kite wrap all'.
                puts "WARNING, Unknown library: \"$lib\""
                continue
            }
            WrapTeapotZip $lib
        }
    }

    # WrapTeapotZip lib
    #
    # lib   - A "lib" from project.kite
    #
    # Wraps a .zip package for the lib.

    proc WrapTeapotZip {lib} {
        # FIRST, make sure the library package exists.
        puts "Wrapping teapot package: $lib [project version]"
        set libdir [project root lib $lib]
        if {![file isdirectory $libdir]} {
            puts [outdent "
                WARNING: Kite could not wrap a teapot .zip file for
                library \"$lib\", because the library package was not
                not found at $libdir.
            "]
            return
        }

        # NEXT, determine the platform to include in the metadata. Use the
        # basekit platform if it differs from the machine *and* is compatible
        set bkplat [DetermineBasekitPlatform]
        set plat   [project provide platform $lib]

        # NEXT, see if the basekit platform is different. If it is but it
        # is not compatible don't switch the platform. 
        if {$bkplat ne $plat} {
            set patterns [platform::patterns $plat]
            if {$bkplat in $patterns} {
                set plat $bkplat
            }
        } 

        # NEXT, create its teapot.txt file
        #
        # TODO: Get external project requires from the lib's 
        # pkgModules.tcl file, and add
        #
        #    Meta require {$package $version}
        #
        # to the teapot.txt
        set contents "Package $lib [project version]\n"                         \

        append contents \
            "Meta description [project name]: [project description]\n" \
            "Meta entrykeep\n"                                         \
            "Meta included *\n"                                        \
            "Meta platform $plat\n"

        writefile [project root lib $lib teapot.txt] $contents

        # NEXT, save the package file.
        set zipname [project provide zipfile $lib]
        set zipfile [file join [project zippath] $zipname]

        try {
            zipper folder $libdir $zipfile -recurse
        } on error {result} {
            throw FATAL "Error wrapping lib $lib; see $logfile:\n$result"
        }
    }
    
    # DetermineBasekitPlatform
    #
    # This proc figures out which platform the basekit was built on by
    # extracting that information from the basekit metadata using the
    # teapot-pkg command.  The platform is a required keyword so it must
    # be there.  The extracted platform is returned.

    proc DetermineBasekitPlatform {} {
        # FIRST, get the basekit metadata
        set basekit [plat pathto basekit.tcl]

        try {
            set meta [exec teapot-pkg show -x $basekit]
        } on error {result} {
            throw FATAL "Could not determine basekit metadata:\n$result"
        }

        # NEXT, extract the platform from the metadata, it is 
        # a required keyword, so it better be there.
        set index [lsearch -exact $meta platform]
        return [lindex $meta $index+1]
    }

    #-------------------------------------------------------------------
    # Clean up

    # clean
    #
    # Cleans up all wrap products produced by this tool.

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
            lappend result [project root bin [project app binfile $name]]
        }

        return $result
    }
}






