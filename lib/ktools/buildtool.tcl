#-----------------------------------------------------------------------
# TITLE:
#   buildtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "build" tool.  By default, this builds all of the build 
#   targets: apps, appkits, and libkits.
#
#   TODO: Allow building just one.
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

    * Appkits will be built as bin/<name>.kit
}

#-----------------------------------------------------------------------
# buildtool ensemble

snit::type ::ktools::buildtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.
    #
    # TODO: Allow building just one target.

    typemethod execute {argv} {
        checkargs build 0 0 {} $argv

        # TODO: retrieve all dependencies
        # TODO: Build documentation

        # TODO: build any app

        # NEXT, build any appkit
        if {[project appkit] ne ""} {
            $type BuildAppKit [project appkit]
        }

        # NEXT, build lib packages.
    }
    

    #-------------------------------------------------------------------
    # Building AppKits

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

    typemethod BuildAppKit {name} {
        # FIRST, do we have the main script
        set main [project root bin $name.tcl]

        if {![file exists $main]} {
            throw fatal \
                "Cannot build appkit '$name'; the 'bin/$name.kit script is missing."
        }

        # FIRST, begin to build up the command.
        set command [list ]
        lappend command \
            -ignorestderr --       \
            tclapp $main           \
            [project root lib * *]


        # NEXT, do we have any libraries?
        if {[llength [glob -nocomplain [project root lib *]]] > 0} {
            lappend command [project root lib * *]
        }

        # NEXT, include library subdirectories, if any.
        if {[llength [glob -nocomplain [project root lib * * *]]] > 0} {
            lappend command [project root lib * * *]
        }


        # NEXT, erase the existing kit, if any
        set kit [project root bin $name.kit]

        if {[file exists $kit]} {
            vputs "Deleting old $name.kit"
            catch {file delete -force $kit}
        }

        # NEXT, prepare to write logfile.
        set logfile [project root .kite build_$name.log]
        file mkdir [file dirname $logfile]

        # NEXT, other standard arguments.

        # TODO: Snit should be an explicit dependency.
        lappend command \
            -out     $kit                            \
            -archive [GetTeapotDir]                  \
            -pkgref  "snit -require 2.3"             \
            >&       $logfile


        # NEXT, Build the appkit

        puts "Building $name.kit as '$kit'"
        puts "See $logfile for details.\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building $name.kit; see $logfile:\n$result"
        }
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
    
}



