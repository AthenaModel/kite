#-----------------------------------------------------------------------
# TITLE:
#   helptool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "help" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(help) {
    arglist     {}
    package     ktools
    ensemble    ::ktools::helptool
    description "Display this help, or help for a given tool."
    intree      no
}

#-----------------------------------------------------------------------
# tool::help ensemble

snit::type ::ktools::helptool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type variables

    # TBD

    #-------------------------------------------------------------------
    # Execution

    # execute ?args?
    #
    # Displays the Kite help.
    #
    # TODO: provide help for individual tools.

    typemethod execute {argv} {
        checkargs help 0 1 {?topic?} $argv

        set topic [lindex $argv 0]

        if {$topic eq ""} {
            ShowTopicList
        } else {
            ShowTopic $topic
        }
    }

    # ShowTopicList 
    #
    # List all of the help topics (i.e., the tools and their descriptions).

    proc ShowTopicList {} {
        puts "Kite is a tool for working with Tcl projects.\n"

        puts "Several tools are available:\n"

        foreach tool [lsort [array names ::ktools]] {
            array set tdata $::ktools($tool)

            puts [format "%-10s - %s" $tool $tdata(description)]
        }

        puts ""

        puts "\nEnter 'kite.kit help <topic>' for help on a given topic."

        puts ""
    }

    # ShowTopic topic
    #
    # topic  - A help topic (possibly)

    proc ShowTopic {topic} {
        # TODO: Provide help for at least the standard tools.

        # For "help", all we can do is display the basic help again.
        if {$topic eq "help"} {
            ShowTopicList
            return
        }

        puts "No help is currently available for that topic."
        puts ""
    }
}



