#-----------------------------------------------------------------------
# TITLE:
#   hook.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: app_kite(n) Code to run project hooks.
#
#-----------------------------------------------------------------------

snit::type hook {
    pragma -hasinstances no

    #-------------------------------------------------------------------
    # Type Variables

    #-------------------------------------------------------------------
    # Public Commands

    # run when phase
    #
    # Retrieves the hook scripts for the given time and phase, and 
    # executes them in a slave interpreter in which the project code
    # is available.

    typemethod run {when phase} {
        # FIRST, are there any scripts? If not, there's nothing to do.
        set scripts [project hook $when $phase]

        if {![got $scripts]} {
            return
        }

        # NEXT, execute the scripts, and show the results to the user.
        puts "\n*** Executing hook: $when $phase"
        puts [tclsh script [join $scripts \n]]
    }

}

