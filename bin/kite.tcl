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

if {[info exists env(TCLLIBPATH)]} {
    set old_path $auto_path
    set auto_path [list]

    foreach dir $old_path {
        if {$dir ni $env(TCLLIBPATH)} {
            lappend auto_path $dir
        }
    }
}

# Next, get the Kite-specific library directories.  Whether we're
# in a starkit or not, the libraries can be found relative to this
# script file.

set appdir  [file normalize [file dirname [info script]]]
set libdir  [file normalize [file join $appdir .. lib]]

# Add Kite libs to the new lib path.
lappend auto_path $libdir

#-------------------------------------------------------------------
# Next, require Tcl/Tk and other required packages.

package require Tcl 8.6
package require snit 2.3
package require ktools

namespace import ktools::*

#-----------------------------------------------------------------------
# Main Program 

# main argv
#
# argv       Command line arguments
#
# This is the main program; it is invoked at the bottom of the file.
# It determines the application to invoke, and does so.

proc main {argv} {
    puts "Project Root: [project root]"
}


#-----------------------------------------------------------------------
# Run the program

try {
    main $argv
} trap FATAL {result} {
    # A fatal application error; result is a message intended
    # for the user.
    puts $result
} on error {result eopts} {
    # A genuine error; report it in detail.
    puts "Unexpected Error: $result"
    puts "\nStack Trace:\n[dict get $eopts -errorinfo]"
}


