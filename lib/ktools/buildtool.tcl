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

    typemethod execute {argv} {
        checkargs build 0 0 {} $argv

        # TODO: retrieve all dependencies
        # TODO: Build documentation

        # TODO: build all apps

        # NEXT, build all appkits
        foreach name [project appkits] {
            $type BuildAppKit $name
        }

        # TODO: build libkits
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
        # FIRST, begin to build up the command.
        set command [list tclapp]

        # NEXT, do we have the main script
        set main [project root bin $name.tcl]

        if {![file exists $main]} {
            throw fatal \
                "Cannot build appkit '$name'; the 'bin/$name.kit script is missing."
        }

        lappend command $main

        # NEXT, erase the existing kit, if any
        set kit [project root bin $name.kit]

        # TODO: erase existing kit; because if we have an error and the
        # old kit is still around, it's a source of confusion.
        if {[file exists $kit]} {
            puts "Deleting old $name.kit"
            catch {file delete -force $kit}
        }

        # NEXT, do we have any libraries?
        if {[llength [glob -nocomplain [project root lib *]]] > 0} {
            lappend command [project root lib * *]
        }

        # NEXT, does any library have a subdirectory?
        if {[llength [glob -nocomplain [project root lib * *]]] > 0} {
            lappend command [project root lib * * *]
        }


        # NEXT, other standard arguments.

        # TODO: Snit should be an explicit dependency.
        lappend command \
            -out $kit   \
            -log [project root build_$name.log] \
            -archive [GetTeapotDir]             \
            -pkgref "snit -require 2.3"

        # NEXT, Build the appkit

        puts "Building $name.kit as '$kit'\n"

        try {
            eval exec $command
        } on error {result} {
            throw FATAL "Error building $name.kit; see build_$name.log:\n$result"
        }
    }

    #-------------------------------------------------------------------
    # Helpers

    # GetTeapotDir
    #
    # For ActiveTcl, the default teapot is in $TCL_HOME/lib/teapot.
    #
    # TODO: Kite should have its own local teapot on the machine.

    proc GetTeapotDir {} {
        set shell [info nameofexecutable]
        set tclhome [file dirname [file dirname $shell]]
        set teapot [file join $tclhome lib teapot]

        return $teapot
    }
    
}



