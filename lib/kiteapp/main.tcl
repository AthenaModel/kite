#-----------------------------------------------------------------------
# TITLE:
#   main.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite main program, as called by the apploader script, kite.tcl.
#
#-----------------------------------------------------------------------

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
        UseTool help
        return
    }

    # NEXT, get any options
    while {[string match "-*" [lindex $argv 0]]} {
        set opt [lshift argv]

        switch -exact -- $opt {
            -verbose  { set ::kiteapp::verbose 1               }
            default   { throw FATAL "Unknown option: \"$opt\"" }
        }
    }

    # NEXT, get the subcommand and see if we have a matching tool.
    # Alternatively, we might have a script fileto run.
    set tool [lshift argv]
    set treeNeeded 0

    if {[file isfile $tool]} {
        set script [file normalize $tool]
        set tool "RunScript"
        set treeNeeded 1
    } elseif {[info exist ktools($tool)]} {
        set treeNeeded [dict get $ktools($tool) intree]
    } else {
        throw FATAL [outdent "
            '$tool' is neither the name of a Kite tool, nor the name of a
            TCL script to execute.  See 'kite help' for usage information.
        "]
    }

    # NEXT, find the root of the project tree, if any.
    project root

    # NEXT, check whether the tool in question requires a project tree
    # or not.  If it does, load the project info.

    if {$treeNeeded} {
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
    if {$tool eq "RunScript"} {
        RunScript $script $argv
    } else {
        UseTool $tool $argv
    }
}

# UseTool tool ?args...?
#
# tool - A registered Kite tool
# argv - Command-line arguments.
#
# Calls the tool with the given arguments.

proc UseTool {tool {argv ""}} {
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

# RunScript filename ?args...?
#
# filename  - Name of a script file
# argv      - Command-line arguments.
#
# Invokes the script in the context of the project.

proc RunScript {filename {argv ""}} {
    # TODO: We need a platform module!
    set ::env(TCLLIBPATH) [project libpath]
    exec tclsh $filename {*} >@ stdout 2>@ stderr
}