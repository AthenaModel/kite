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
        tclsh        {}
        teacup       {}
        tkcon        {}
        basekit.tcl  {}
        basekit.tk   {}
    }

    # pathsOf - important directories, by symbolic name.

    typevariable pathsOf -array {
        tclhome  {}
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

    # tableof pathsto
    #
    # Returns a table of information about the pathto results.

    typemethod {tableof pathsto} {} {
        set table [list]

        foreach name [lsort [array names pathsTo]] {
            set path [plat pathto $name]

            if {$path eq ""} {
                set path "(NOT FOUND)"
            }

            lappend table [list name $name path $path]
        }

        return $table
    }

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
                set path [os pathfind [os exefile tclsh]]
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

            basekit.tcl {
                set path [FindBasekit tcl]
            }

            basekit.tk {
                set path [FindBasekit tk]
            }

            default { error "Unknown symbolic name: \"$name\""}
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
    
    # FindBaseKit tcltk
    #
    # tcltk  - tcl | tk
    #
    # Finds the basekit executable, based on the platform.

    proc FindBasekit {tcltk} {
        # FIRST, determine the base-kit pattern.
        #
        # TODO: We should query the development tclsh to get this, rather 
        # than assuming we're running on the development tclsh.
        set tv     [info tclversion]
        set prefix "base-${tcltk}${tv}-thread*"

        switch [os flavor] {
            "windows" {
                set basedir [file dirname [plat pathto tclsh -required]]
            }
            "osx" {
                set basedir "/Library/Tcl/basekits"
            }
            "linux" {
                set basedir [file dirname [plat pathto tclsh -required]]

            }
            default "Unknown OS flavor: \"[os flavor]\""
        }

        set pattern  [file join $basedir [os exefile $prefix]]
        set allfiles [glob -nocomplain $pattern]

        # NEXT, strip out library files
        foreach file $allfiles {
            if {[file extension $file] in {.dll .dylib .so}} {
                continue
            }

            return $file
        }

        return ""
    }

    #-------------------------------------------------------------------
    # Paths of important directories

    # tableof pathsof
    #
    # Returns a table of information about the pathof results.

    typemethod {tableof pathsof} {} {
        set table [list]

        foreach name [lsort [array names pathsOf]] {
            set path [plat pathof $name]

            if {$path eq ""} {
                set path "(NOT FOUND)"
            }

            lappend table [list name $name path $path]
        }

        return $table
    }


    # pathof name ?options? 
    #
    # name  - Symbolic name of an important directory.
    #
    # Options:
    #    -required  - It's a fatal error if the directory cannot be found.
    #
    # Attempts to determine the path to the directory, taking the OS flavor
    # into account as needed.  Returns the normalized path, or "" if
    # it can't find it.

    typemethod pathof {name args} {
        # FIRST, get the options.
        set required 0
        foroption opt args {
            -required { set required 1 }
        }

        # NEXT, if we already have it just return it.
        if {$pathsOf($name) ne ""} {
            return $pathsOf($name)
        }

        # NEXT, get the path.
        switch -exact -- $name {
            tclhome {
                set tclsh [plat pathto tclsh]

                if {$tclsh eq ""} {
                    set path ""
                } else {
                    set path [file dirname [file dirname $tclsh]]
                }
            }

            default { error "Unknown symbolic name: \"$name\""}
        }

        if {[file isdirectory $path]} {
            set pathsOf($name) [file normalize $path]
        }

        if {$required && $pathsOf($name) eq ""} {
            throw FATAL [outdent "
                Kite needs the '$name' directory to perform the requested 
                action, but cannot locate it on the disk.
            "]
        }

        return $pathsOf($name)
    }
}


