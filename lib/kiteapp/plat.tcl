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
    # Constants

    # osNames, by flavor

    typevariable osNames -array {
        linux    "Linux"
        osx      "Mac OS X"
        windows  "Windows"
    }
    

    #-------------------------------------------------------------------
    # Type Variables

    # info - Cached info
    #
    # flavor              - The OS flavor: linux|osx|windows
    #
    
    typevariable info -array {
        flavor {}
    }

    # pathsTo - important files, by symbolic name.

    typevariable pathsTo -array {
        tclsh  {}
        teacup {}
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
            set info($key) {}
        }

        foreach key [array names pathsTo] {
            set pathsTo($key) {}
        }
    }

    # flavor
    #
    # Returns the platform flavor, one of linux|osx|windows.
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
    
    typemethod flavor {} {
        if {$info(flavor) eq ""} {
            switch -glob -- $::tcl_platform(os) {
                "Windows*" { set info(flavor) windows }
                "Darwin*"  { set info(flavor) osx     }
                default    { set info(flavor) linux   }
            }
        }

        return $info(flavor)
    }

    # osname
    #
    # Returns the OS name for the platform flavor. 
    
    typemethod osname {} {
        return $osName([plat flavor])
    }

    # exefile name
    #
    # name - A program name or path
    #
    # Given the program name or path, adds on the appropriate file 
    # extensions for executables on this platfor.

    typemethod exefile {name} {
        if {[plat flavor] eq "windows" && 
            [file extension $name] != ".exe"
        } {
            return "$name.exe"
        } else {
            return $name
        }
    }

    #-------------------------------------------------------------------
    # Paths to important files

    # pathto name ?options? 
    #
    # name  - Symbolic name of an important file.
    #
    # Options:
    #    -required  - It's a fatal error if the file cannot be found.
    #
    # Attempts to determine the path to the file, taking the OS flavor
    # into account as needed.  Returns the normalized path, or "" if
    # it can't find it.

    typemethod pathto {name args} {
        # FIRST, get the options.
        set required 0
        foroption opt args {
            -required { set required 1 }
        }

        # NEXT, if we already have it just return it.
        if {$pathsTo($name) ne ""} {
            return $pathsTo($name)
        }

        # NEXT, get the path.
        switch -exact -- $name {
            tclsh {
                # TODO: We should find this on the path.
                set path [info nameofexecutable]
            }

            teacup {
                set bindir [file dirname [plat pathto tclsh]]
                set path [file join $bindir [plat exefile $name]]

                # TODO: If it isn't next to the tclsh, see if we can
                # find it on the path.
            }
        }

        if {[file isfile $path]} {
            set pathsTo($name) [file normalize $path]
        }

        if {$required && $pathsTo($name) eq ""} {
            throw FATAL [outdent "
                Kite needs '$name' to perform the requested action,
                but cannot locate it on the disk.
            "]
        }

        return $pathsTo($name)
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


