#-----------------------------------------------------------------------
# TITLE:
#   metadata.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: app_kite(n) metadata project transformer
#
#   This module is responsible for updating project code files to
#   match the project metadata.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# metadata ensemble

snit::type metadata {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no


    #-------------------------------------------------------------------
    # Saving project metadata for use by the project's own code.

    # apply
    #
    # Applies the current project metadata to the project files.

    typemethod apply {} {
        # FIRST, if there's an app save the kiteinfo package for
        # its use.
        if {[got [project app names]]} {
            subtree kiteinfo [project getinfo]
        }

        # NEXT, for each library in $root/lib, update its version number
        # and requirements in the pkgIndex and pkgModules files.
        # Packages can opt out by removing the "-kite" tags.
        foreach lib [project globdirs lib *] {
            UpdateLibMetadata [file tail $lib]
        }
    }

    # UpdateLibMetadata lib
    #
    # lib   - Name of a library package
    #
    # Updates the version number and requires in the pkgIndex.tcl and 
    # pkgModules.tcl files for the given library.

    proc UpdateLibMetadata {lib} {
        try {
            # FIRST, pkgIndex.tcl
            set fname [project root lib $lib pkgIndex.tcl]

            if {[file exists $fname]} {
                set oldText [readfile $fname]
                set content "package ifneeded $lib [project version] "
                append content \
                    {[list source [file join $dir pkgModules.tcl]]}

                set newText [blockreplace $oldText ifneeded $content]

                writefile $fname $newText -ifchanged
            }

            # NEXT, pkgModules.tcl
            set fname [project root lib $lib pkgModules.tcl]

            if {[file exists $fname]} {
                # FIRST, update "package provide".
                set text1 [readfile $fname]
                set content "package provide $lib [project version]"
                set text2 [blockreplace $text1 provide $content]

                # NEXT, update "package require"
                set newlines [list]
                foreach line [blocklines $text2 require] {
                    lappend newlines [UpdateRequireLine $line]
                }

                set content [join $newlines \n]
                set text3 [blockreplace $text2 require $content]
                writefile $fname $text3 -ifchanged
            }
        } trap POSIX {result} {
            throw FATAL "Error updating \"$lib\" version: $result"
        }
    }

    # UpdateRequireLine line
    #
    # line   - A line of text in a "require" block.
    #
    # Replaces "package require" versions with correct versions.

    proc UpdateRequireLine {line} {
        # FIRST, get the leader, and normalize the line.
        regexp {^\s*} $line leader
        set input [normalize $line]

        # NEXT, is it a package require line?
        if {![string match "package require *" $input]} {
            return $line
        } else {
            set newline "${leader}package require "
        }

        # NEXT, is there a "-exact"?
        set input [lrange [split $input] 2 end]
        set exact 0

        if {[lindex $input 0] eq "-exact"} {
            set exact 1
            lshift input
        }

        # NEXT, what package is it?
        set pkg [lshift input]

        if {$pkg in [project require names]} {
            if {$exact} {
                append newline "-exact "
            }
            append newline "$pkg "

            append newline [project require version $pkg]
        } elseif {$pkg in [project provide names]} {
            append newline "-exact $pkg [project version]"
        } else {
            set newline $line
        }

        return $newline
    }
}





