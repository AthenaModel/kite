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

    # pathsTo - important files, by symbolic name.

    typevariable pathsTo -array {
        tclsh  {}
        teacup {}
        tkcon  {}
    }

    #-------------------------------------------------------------------
    # Queries

    # reset
    #
    # In the unlikely event that Kite changes something and then needs
    # to reload platform-specific info, this command will clear the
    # cache.

    typemethod reset {} {
        foreach key [array names pathsTo] {
            set pathsTo($key) {}
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
                set path [FindNear tclsh [os exefile teacup]]
            }

            tkcon {
                set name "tkcon"
                if {[os flavor] eq "windows"} {
                    append name ".tcl"
                }

                set path [FindNear tclsh $name]
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

    # FindNear tool filename
    #
    # tool      - A known tool
    # filename  - A file name
    #
    # Looks for the filename in the same directory as the known tool.
    # If not found, looks on the PATH.

    proc FindNear {tool filename} {
        set dir [file dirname [plat pathto $tool]]

        set path [file join $dir $filename]

        if {[file isfile $path]} {
            return $path
        }

        return [os pathfind $filename]
    }
    

    #-------------------------------------------------------------------
    # Paths of important directories

    # pathof tclhome
    #
    # The normalized directory path to the "TCL Home" directory.
    #
    # TODO: this should be a configurable parameter.

    typemethod {pathof tclhome} {} {
        set tclsh [plat pathto tclsh]

        if {$tclsh eq ""} {
            return ""
        } else {
            set home [file dirname [file dirname $tclsh]]
            return [file normalize $home]
        }
    }
    
    
}


