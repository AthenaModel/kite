#!/bin/sh
# -*-tcl-*-
# The next line restarts using tclsh \
exec tclsh "$0" "$@"

#-----------------------------------------------------------------------
# TITLE:
#    kite.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    Kite: Application Launcher
#
#    This script serves as the main entry point for the Kite
#    tool.  The tool is invoked using 
#    the following syntax:
#
#        $ kite ?args....?
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Set up the auto_path, so that we can find the correct libraries.  
# In development, there might be directories loaded from TCLLIBPATH;
# strip them out.

# First, remove all TCLLIBPATH directories from the auto_path.
#
# NOTE: This code prevents kite.tcl from loading erroneous packages
# in development.  It fails in kite.kit because it executes after the 
# first package require.  In kite.kit, that occurs immediately at the 
# top of the starkit.  It might be better to plan to build Kite as an exe.

if {[info exists env(TCLLIBPATH)]} {
    set old_path $auto_path
    set auto_path [list]

    foreach dir $old_path {
        if {$dir ni $env(TCLLIBPATH)} {
            lappend auto_path $dir
        }
    }

    set env(TCLLIBPATH) [list]
}

# Next, get the Kite-specific library directories.  Whether we're
# in a starkit or not, the libraries can be found relative to this
# script file.

set appdir  [file normalize [file dirname [info script]]]
set libdir  [file normalize [file join $appdir .. lib]]

# Add Kite libs to the new lib path.
set auto_path [linsert $auto_path 0 $libdir]

#-------------------------------------------------------------------
# Next, require Tcl/Tk and kiteinfo

package require Tcl 8.6
package require kiteinfo

#-----------------------------------------------------------------------
# Next, require kiteapp; it will define the main program.

package require kiteapp

#-----------------------------------------------------------------------
# Run the program

try {
    # Allow for interactive testing
    if {!$tcl_interactive} {
        main $argv
    }
} trap FATAL {result} {
    # A fatal application error; result is a message intended
    # for the user.
    puts $result
    puts ""
} on error {result eopts} {
    # A genuine error; report it in detail.
    puts "Unexpected Error: $result"
    puts "\nStack Trace:\n[dict get $eopts -errorinfo]"
}


