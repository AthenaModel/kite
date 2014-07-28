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
# Next, require Tcl/Tk and kiteinfo, so we can require other packages.

package require Tcl 8.6
package require kiteinfo

#-----------------------------------------------------------------------
# Require other needed packages.

# FIXME: should be in kiteapp/pkgModules.tcl, in -kite-require block.
package require snit

package require kiteapp
namespace import kiteutils::*
namespace import kiteapp::*

puts "kiteutils: $kiteutils::library"

#-----------------------------------------------------------------------
# Main Program 

# main argv
#
# argv       Command line arguments
#
# This is the main program; it is invoked at the bottom of the file.
# It determines the application to invoke, and does so.

proc main {argv} {
    global ktools
    global kopts

    # FIRST, given no input display the help; help doesn't care whether
    # we're in a project tree or not.
    if {[llength $argv] == 0} {
        usetool help
        return
    }

    # NEXT, get any options
    while {[string match "-*" [lindex $argv 0]]} {
        set opt [lshift argv]

        switch -exact -- $opt {
            -verbose  { set ::kutils::verbose 1                }
            default   { throw FATAL "Unknown option: \"$opt\"" }
        }
    }

    # NEXT, get the subcommand and see if we have a matching tool.
    set tool [lshift argv]

    if {![info exist ktools($tool)]} {
        throw FATAL \
            "'$tool' is not the name of a Kite tool.  See 'kite help'."
    }

    # NEXT, find the root of the project tree, if any.
    project root

    # NEXT, check whether the tool in question requires a project tree
    # or not.  If it does, load the project info.

    if {[dict get $ktools($tool) intree]} {
        if {![project intree]} {
            throw FATAL \
                "Could not find project.kite in this directory or its parents"
        }

        project loadinfo
    }

    # NEXT, If we have a project tree then save the project info to the 
    # kiteinfo package so that the
    # project's code has access to it at run-time.  Note that the content
    # will change only if the project's project.kite file has changed
    # (or if Kite itself changes the data being saved).
    #
    # Thus, saving it everytime guarantees that the code is always
    # up-to-date without generating a stream of changes into the 
    # VCS repository.

    if {[project hasinfo]} {
        project metadata save
    }

    # NEXT, use the tool, passing it the remaining arguments.
    usetool $tool $argv
}

# usetool tool ?args...?
#
# tool - A registered Kite tool
# argv - Command-line arguments.
#
# Calls the tool with the given arguments.

proc usetool {tool {argv ""}} {
    array set tdata $::ktools($tool)

    # FIRST, make sure the tool's package is loaded.
    # NOTE: At present, this isn't strictly required; all tools
    # are defined in ktools(n), which is loaded automatically.
    # In the long run, we will have tools (and external plugins)
    # that are loaded only when called for.
    package require $tdata(package)

    # NEXT, execute it.
    $tdata(ensemble) execute $argv
}

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


