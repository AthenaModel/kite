#-----------------------------------------------------------------------
# TITLE:
#   teapot.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) teapot module; commands for using the "teacup"
#   executable to create and administrate the local teapot repository
#   as a whole.  Use teacup.tcl to query the local teapot repository
#   and to install packages.
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export teapot
}

#-----------------------------------------------------------------------
# teapot ensemble

snit::type ::kutils::teapot {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no


    # status
    #
    # Displays information about the local teapot.

    typemethod status {} {
        set state [$type state]

        puts "Local teapot: [project teapot]\n"

        switch -exact -- $state {
            missing {
                puts "Kite hasn't yet created its local teapot. Please use"
                puts "'kite teapot create' to do so.  See 'kite help teapot'"
                puts "for details."
            }

            non-default {
                puts "Kite's local teapot isn't the default installation"
                puts "teapot.  Please use 'kite teapot create' to make it"
                puts "so.  See 'kite help teapot' for details."
            }

            unlinked {
                puts "Kite's local teapot isn't linked to the development"
                puts "tclsh.  Please use 'kite teapot link' to do so."
                puts "See 'kite help teapot' for details."
            }

            ok {
                puts "Kite's local teapot is ready for use."
            }

            default {
                error "Unknown teapot state: \"$state\""
            }
        }
    }


    # create
    #
    # Creates the Kite teapot, if need be, and links it to the
    # current tclsh.

    typemethod create {} {
        # FIRST, create the teapot
        if {[$type state] eq "missing"} {
            puts "Creating teapot at [project teapot]..."
            file mkdir [file dirname [project teapot]]
            lappend command \
                teacup create [project teapot]

            eval exec $command
        }

        # NEXT, make it the default teapot.
        puts "Making Kite teapot the default installation teapot."
        exec teacup default [project teapot] 

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
        puts "Linking Kite teapot to [info nameofexecutable]..."
        try {
            exec teacup link make [project teapot] [info nameofexecutable]
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
        puts "Unlinking Kite teapot from [info nameofexecutable]..."
        exec teacup link cut [project teapot] [info nameofexecutable]

        # NEXT, remove it it.
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

        if {[project teapot] ne [DefaultTeapot]} {
            return "non-default"
        }

        if {[TeapotIsLinked]} {
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
            [project teapot]        in [LinkedTeapots] &&
            [info nameofexecutable] in [LinkedShells]            
        }
    }

    # LinkedShells
    #
    # Retrieves the shells linked to the local teapot

    proc LinkedShells {} {
        set links [eval exec teacup link info [project teapot]]
        set links [string map {\\ /} $links] 

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
        set links [eval exec teacup link info [info nameofexecutable]]
        set links [string map {\\ /} $links] 

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

    # DefaultTeapot
    #
    # Retrieves the default teapot.

    proc DefaultTeapot {} {
        set def [eval exec teacup default]
        set def [string map {\\ /} $def] 

        return [file normalize $def]
    }



}