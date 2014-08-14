#-----------------------------------------------------------------------
# TITLE:
#   plat.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Platform-indepence layer.
#
#   This module is the API for all code that depends on the platform in
#   use.  It may implement the required functionality itself, or 
#   farm it out to platform-specific modules.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# plat ensemble

snit::type plat {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type Variables

    # info - Cached info
    #
    # id              - The OS ID: linux|osx|windows
    #
    
    typevariable info -array {
        id {}
    }
    

    #-------------------------------------------------------------------
    # Queries

    # reset
    #
    # In the unlikely event that Kite changes something and then needs
    # to reload platform-specific info, this command will clear the
    # cache.

    typemethod reset {} {
        foreach key [array names info] {
            set info($key) ""
        }
    }

    # id
    #
    # Returns the platform ID, one of linux|osx|windows.
    #
    # This is the routine that figures out what kind of machine we're
    # on.  These selectors are enough for most purposes; for actually
    # setting the "arch", see the standard platform(n) package.
    #
    # Note: if we aren't on Windows or OS X, we assume we're on Linux,
    # or something enough like it not to matter.
    #
    # Other parts of the code can query this, if need be; but if they
    # do the function may need to be refactored into this API. 
    
    typemethod id {} {
        if {$info(id) eq ""} {
            switch -glob -- $::tcl_platform(os) {
                "Windows*" { set info(id) windows }
                "Darwin*"  { set info(id) osx     }
                default    { set info(id) linux   }
            }
        }

        return $info(id)
    }


    #-------------------------------------------------------------------
    # Paths of important directories

    # pathof tclhome
    #
    # The normalized directory path to the "TCL Home" directory.
    #
    # TODO: this should be derived from "pathto tclsh" by default, and
    # should be a configurable parameter.

    typemethod {pathof tclhome} {} {
        set tclsh [info nameofexecutable]
        set home [file dirname [file dirname $tclsh]]

        return [file normalize $home]
    }
    
    
}


