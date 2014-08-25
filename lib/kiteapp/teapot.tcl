#-----------------------------------------------------------------------
# TITLE:
#   teapot.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) teapot module.  This module manages the local teapot,
#   ensuring that Kite can easily use it to access its external dependencies.
#
#   This module is responsible for the local teapot as a whole; see 
#   deps.tcl for code relating to a project's external dependencies.
#   Also, teacup.tcl is a proxy to the teacup.exe program.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# teapot ensemble

snit::type teapot {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # create
    #
    # Creates the Kite teapot, if need be, and links it to the
    # current tclsh.
    #
    # TODO: We need a better place to get the local teapot name.

    typemethod create {} {
        # FIRST, create the teapot
        if {[$type state] eq "missing"} {
            puts "Creating teapot at [project teapot]..."
            teacup create [project teapot]
        }

        # NEXT, make it the default teapot.
        puts "Making Kite teapot the default installation teapot."
        teacup default [project teapot] 

        # NEXT, suggest that the user link it.
        puts ""
        puts [outdent {
            Next, link the new teapot to your tclsh using

                $ kite teapot link

            If you are on Linux or OS X you will probably need to
            use "sudo" for this step.

                $ sudo kite teapot link
        }]
    }


    # link
    #
    # Links the Kite teapot to the current tclsh.

    typemethod link {} {
        puts "Linking Kite teapot to [plat pathto tclsh -required]..."
        try {
            teacup link make [project teapot] [plat pathto tclsh]
        } trap CHILDSTATUS {result eopts} {
            if {[string match "*cannot be written.*" $result]} {
                puts "Error: $result"
                puts ""
                puts "Consider using 'sudo -E'.  See 'kite help teapot' for details.\n"
                throw FATAL \
                    "Failed to link [project teapot] to the tclsh."
            } else {
                # Rethrow
                return {*}$eopts $result
            }
        }
    }

    # remove
    #
    # Unlinks the Kite teapot from the current tclsh, and removes it
    # from the disk.

    typemethod remove {} {
        # FIRST, unlink the teapot.
        puts "Unlinking Kite teapot from [plat pathto tclsh -required]..."
        teacup link cut [project teapot] [plat pathto tclsh]

        # NEXT, remove it.
        puts "Removing [project teapot] from disk"
        file delete -force [project teapot]
    }

    #-------------------------------------------------------------------
    # Determining the state of the local teapot.
    
    # state
    #
    # Verifies whether we have a Kite teapot or not.  Returns one 
    # of the following:
    #
    # ok          - Project teapot exists and is linked to tclsh
    # non-default - Project teapot isn't the default teapot.
    # unlinked    - Project teapot exists but is not linked to tclsh
    # missing     - Project teapot does not exist

    typemethod state {} {
        if {![file exists [project teapot]]} {
            return "missing"
        }

        if {[project teapot] ne [teacup default]} {
            return "non-default"
        }

        if {![TeapotIsLinked]} {
            return "unlinked"
        }

        return "ok"
    }

    # TeapotIsLinked
    #
    # The teapot is linked if both of the following are true:
    #
    # * The teapot knows that it is linked to the current tclsh
    # * The current tclsh knows that it is linked to the teapot.

    proc TeapotIsLinked {} {
        expr {
            [project teapot]     in [LinkedTeapots] &&
            [plat pathto tclsh]  in [LinkedShells]            
        }
    }

    # LinkedShells
    #
    # Retrieves the shells linked to the local teapot

    proc LinkedShells {} {
        set links [teacup link info [project teapot]]

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

    # LinkedTeapots
    #
    # Retrieves the teapots linked to the current tclsh.

    proc LinkedTeapots {} {
        set links [teacup link info [plat pathto tclsh]]

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

}

